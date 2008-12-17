Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DBB0E6B00AE
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 17:46:26 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id mBHMmFCW012038
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:48:15 -0800
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by spaceape24.eur.corp.google.com with ESMTP id mBHMlkqd014137
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:48:13 -0800
Received: by rv-out-0708.google.com with SMTP id c5so127282rvf.34
        for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:48:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081217140741.0085e6a0.akpm@linux-foundation.org>
References: <20081216113055.713856000@menage.corp.google.com>
	 <20081216113653.252690000@menage.corp.google.com>
	 <20081217140741.0085e6a0.akpm@linux-foundation.org>
Date: Wed, 17 Dec 2008 14:48:12 -0800
Message-ID: <6599ad830812171448u642f9d9bsd61cbdda53727cc0@mail.gmail.com>
Subject: Re: [PATCH 3/3] CGroups: Add css_tryget()
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 17, 2008 at 2:07 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>        /*
>         * State maintained by the cgroup system to allow subsystems
>         * to be "busy". Should be accessed via css_get(),
>         * css_tryget() and and css_put().
>         */
>
> is conventional/preferred.

Oops, will fix.

>>  static inline void css_get(struct cgroup_subsys_state *css)
>> @@ -77,9 +80,32 @@ static inline void css_get(struct cgroup
>>       if (!test_bit(CSS_ROOT, &css->flags))
>>               atomic_inc(&css->refcnt);
>>  }
>> +
>> +static inline bool css_is_removed(struct cgroup_subsys_state *css)
>> +{
>> +     return test_bit(CSS_REMOVED, &css->flags);
>> +}
>> +
>> +/*
>> + * Call css_tryget() to take a reference on a css if your existing
>> + * (known-valid) reference isn't already ref-counted. Returns false if
>> + * the css has been destroyed.
>> + */
>> +
>> +static inline bool css_tryget(struct cgroup_subsys_state *css)
>> +{
>> +     if (test_bit(CSS_ROOT, &css->flags))
>> +             return true;
>> +     while (!atomic_inc_not_zero(&css->refcnt)) {
>> +             if (test_bit(CSS_REMOVED, &css->flags))
>> +                     return false;
>> +     }
>> +     return true;
>> +}
>
> This looks too large to inline.
>
> We should have a cpu_relax() in the loop?

Sounds reasonable.

>
> And possibly a cond_resched().

No, we don't want to reschedule. These are pseudo spin locks rather
than psuedo mutexes. And the "hold time" is extremely short.

>
> It would be better if these polling loops didn't exist at all, of
> course.  But I guess if you could work out a way of doing that, this
> patch wouldn't exist.

It would certainly be possible to implement it as a spinlock and a
count, and do:

css_get() {
  spin_lock(&css->lock);
  css->count++;
  spin_unlock(&css->lock);
}

css_tryget() {
  spin_lock(&css->lock);
  if (css->count > 1) {
    css->count++; result = true;
  } else {
    result = false;
  }
  spin_unlock(&css->lock);
}

and implement the cgroups side of it as

for each subsystem {
  spin_lock(&css->lock);
  if (css->count == 1) {
    css->count = 0;
  } else {
    success = false;
  }
}
for each subsystem {
  if (!success && css->count == 0) {
    css->count = 1;
  }
  spin_unlock(&css->lock);
}

Functionally that would be identical - the only downside is that's an
extra atomic operation in the fast path of css_get() and css_tryget(),
which some people had objected to in the past when I proposed similar
patches.

Hmm. Thinking about it, this is very similar to the rwlock_t logic,
and I could probably implement css_get() and css_tryget() via
read_lock() and the clear_css_refs() side via write_trylock(). Which
would be pretty much the same as the original patch, except using
conventional primitives. Big downside would be that we would be
limited to RW_LOCK_BIAS refcounts, or about 16M, versus the 2B that we
get with regular atomics.

Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
