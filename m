Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 184A98E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:41:01 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d194-v6so1909232qkb.12
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:41:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d199-v6si945387qkb.275.2018.09.12.08.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:40:59 -0700 (PDT)
Subject: Re: [PATCH v3 3/4] fs/dcache: Track & report number of negative
 dentries
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-4-git-send-email-longman@redhat.com>
 <20180911220857.GG5631@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <4fdce6b6-7f0a-cef6-8361-2d297702ac38@redhat.com>
Date: Wed, 12 Sep 2018 11:40:56 -0400
MIME-Version: 1.0
In-Reply-To: <20180911220857.GG5631@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 09/11/2018 06:08 PM, Dave Chinner wrote:
> On Tue, Sep 11, 2018 at 03:18:25PM -0400, Waiman Long wrote:
>> The current dentry number tracking code doesn't distinguish between
>> positive & negative dentries. It just reports the total number of
>> dentries in the LRU lists.
>>
>> As excessive number of negative dentries can have an impact on system
>> performance, it will be wise to track the number of positive and
>> negative dentries separately.
>>
>> This patch adds tracking for the total number of negative dentries
>> in the system LRU lists and reports it in the 7th field in the
> Not the 7th field anymore.
>

You are right. It is a left-behind from v2.

>> /proc/sys/fs/dentry-state file. The number, however, does not include
>> negative dentries that are in flight but not in the LRU yet as well
>> as those in the shrinker lists.
>>
>> The number of positive dentries in the LRU lists can be roughly found
>> by subtracting the number of negative dentries from the unused count.
>>
>> Matthew Wilcox had confirmed that since the introduction of the
>> dentry_stat structure in 2.1.60, the dummy array was there, probably f=
or
>> future extension. They were not replacements of pre-existing fields. S=
o
>> no sane applications that read the value of /proc/sys/fs/dentry-state
>> will do dummy thing if the last 2 fields of the sysctl parameter are
>> not zero. IOW, it will be safe to use one of the dummy array entry for=

>> negative dentry count.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> ....
>> ---
>>  Documentation/sysctl/fs.txt | 26 ++++++++++++++++----------
>>  fs/dcache.c                 | 31 +++++++++++++++++++++++++++++++
>>  include/linux/dcache.h      |  7 ++++---
>>  3 files changed, 51 insertions(+), 13 deletions(-)
>>
>> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt=

>> index 819caf8..3b4f441 100644
>> --- a/Documentation/sysctl/fs.txt
>> +++ b/Documentation/sysctl/fs.txt
>> @@ -56,26 +56,32 @@ of any kernel data structures.
>> =20
>>  dentry-state:
>> =20
>> -From linux/fs/dentry.c:
>> +From linux/include/linux/dcache.h:
>>  --------------------------------------------------------------
>> -struct {
>> +struct dentry_stat_t dentry_stat {
>>          int nr_dentry;
>>          int nr_unused;
>>          int age_limit;         /* age in seconds */
>>          int want_pages;        /* pages requested by system */
>> -        int dummy[2];
>> -} dentry_stat =3D {0, 0, 45, 0,};
>> ---------------------------------------------------------------=20
>> -
>> -Dentries are dynamically allocated and deallocated, and
>> -nr_dentry seems to be 0 all the time. Hence it's safe to
>> -assume that only nr_unused, age_limit and want_pages are
>> -used. Nr_unused seems to be exactly what its name says.
>> +        int nr_negative;       /* # of unused negative dentries */
>> +        int dummy;	       /* Reserved */
> /* reserved for future use */

Will change that.

> ....
>> @@ -331,6 +343,8 @@ static inline void __d_clear_type_and_inode(struct=
 dentry *dentry)
>>  	flags &=3D ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
>>  	WRITE_ONCE(dentry->d_flags, flags);
>>  	dentry->d_inode =3D NULL;
>> +	if (dentry->d_flags & DCACHE_LRU_LIST)
>> +		this_cpu_inc(nr_dentry_negative);
>>  }
>> =20
>>  static void dentry_free(struct dentry *dentry)
>> @@ -385,6 +399,10 @@ static void dentry_unlink_inode(struct dentry * d=
entry)
>>   * The per-cpu "nr_dentry_unused" counters are updated with
>>   * the DCACHE_LRU_LIST bit.
>>   *
>> + * The per-cpu "nr_dentry_negative" counters are only updated
>> + * when deleted or added to the per-superblock LRU list, not
>> + * on the shrink list.
> This tells us what the code is doing, but it doesn't explain why
> a different accounting method to nr_dentry_unused was chosen. What
> constraints require the accounting to be done this way rather than
> just mirror the unused dentry accounting?

It is done to minimize the number of percpu count update as much as
possible. There is one code path where the unused count is decremented
when removing from the lru and then increment later on when added to the
shrink list. So we are doing double inc/dec in this case.

Besides, those in the shrink list are on the way out and its number
isn't really that important. I will elaborate a bit more on the
rationale behind this decision in the patch.

>> @@ -1836,6 +1862,11 @@ static void __d_instantiate(struct dentry *dent=
ry, struct inode *inode)
>>  	WARN_ON(d_in_lookup(dentry));
>> =20
>>  	spin_lock(&dentry->d_lock);
>> +	/*
>> +	 * Decrement negative dentry count if it was in the LRU list.
>> +	 */
>> +	if (dentry->d_flags & DCACHE_LRU_LIST)
>> +		this_cpu_dec(nr_dentry_negative);
>>  	hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
>>  	raw_write_seqcount_begin(&dentry->d_seq);
>>  	__d_set_inode_and_type(dentry, inode, add_flags);
>> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
>> index ef4b70f..73ff9f0 100644
>> --- a/include/linux/dcache.h
>> +++ b/include/linux/dcache.h
>> @@ -62,9 +62,10 @@ struct qstr {
>>  struct dentry_stat_t {
>>  	long nr_dentry;
>>  	long nr_unused;
>> -	long age_limit;          /* age in seconds */
>> -	long want_pages;         /* pages requested by system */
>> -	long dummy[2];
>> +	long age_limit;		/* age in seconds */
>> +	long want_pages;	/* pages requested by system */
>> +	long nr_negative;	/* # of unused negative dentries */
>> +	long dummy;		/* Reserved */
> /* reserved for future use */

Will do.

Cheers,
Longman
