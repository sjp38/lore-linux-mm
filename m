Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 1F9A56B0088
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:55:41 -0400 (EDT)
Message-ID: <515D240D.7040901@parallels.com>
Date: Thu, 4 Apr 2013 10:56:13 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 05/28] dcache: remove dentries from LRU before putting
 on dispose list
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-6-git-send-email-glommer@parallels.com> <CAFj3OHU_o5o_n_kcci1U_=M0tCpYEwy8abRvHKBdp-GoJ-cs3w@mail.gmail.com> <20130404061938.GD12011@dastard>
In-Reply-To: <20130404061938.GD12011@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 04/04/2013 10:19 AM, Dave Chinner wrote:
> On Wed, Apr 03, 2013 at 02:51:43PM +0800, Sha Zhengju wrote:
>> On Fri, Mar 29, 2013 at 5:13 PM, Glauber Costa <glommer@parallels.com>wrote:
>>> From: Dave Chinner <dchinner@redhat.com>
>>> @@ -884,6 +907,28 @@ relock:
>>>         shrink_dentry_list(&tmp);
>>>  }
>>>
>>> +/*
>>> + * Mark all the dentries as on being the dispose list so we don't think
>>> they are
>>> + * still on the LRU if we try to kill them from ascending the parent
>>> chain in
>>> + * try_prune_one_dentry() rather than directly from the dispose list.
>>> + */
>>> +static void
>>> +shrink_dcache_list(
>>> +       struct list_head *dispose)
>>> +{
>>> +       struct dentry *dentry;
>>> +
>>> +       rcu_read_lock();
>>> +       list_for_each_entry_rcu(dentry, dispose, d_lru) {
>>> +               spin_lock(&dentry->d_lock);
>>> +               dentry->d_flags |= DCACHE_SHRINK_LIST;
>>> +               this_cpu_dec(nr_dentry_unused);
>>>
>>
>> Why here dec nr_dentry_unused again? Has it been decreased in the following
>> shrink_dcache_sb()?
> 
> You are right, that's a bugi as we've already accounted for the
> dentry being pulled off the LRU list. Good catch.
> 

Ok, I folded it in the original patch with the due credits for better
bisection.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
