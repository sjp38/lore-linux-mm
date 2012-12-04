Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 234146B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 14:15:12 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Tue, 4 Dec 2012 12:15:10 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 100591FF0043
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 12:15:01 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB4JEvZ6206540
	for <linux-mm@kvack.org>; Tue, 4 Dec 2012 12:14:58 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB4JDnLR023551
	for <linux-mm@kvack.org>; Tue, 4 Dec 2012 12:13:55 -0700
Message-ID: <50BE4B64.6000003@linaro.org>
Date: Tue, 04 Dec 2012 11:13:40 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v2] Support volatile range for anon vma
References: <1351560594-18366-1-git-send-email-minchan@kernel.org> <50AD739A.30804@linaro.org> <50B6E1F9.5010301@linaro.org> <20121204000042.GB20395@bbox> <50BD4A70.9060506@linaro.org> <20121204072207.GA9782@blaptop>
In-Reply-To: <20121204072207.GA9782@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/03/2012 11:22 PM, Minchan Kim wrote:
> On Mon, Dec 03, 2012 at 04:57:20PM -0800, John Stultz wrote:
>> On 12/03/2012 04:00 PM, Minchan Kim wrote:
>>> On Wed, Nov 28, 2012 at 08:18:01PM -0800, John Stultz wrote:
>>>> On 11/21/2012 04:36 PM, John Stultz wrote:
>>>>> 2) Being able to use this with tmpfs files. I'm currently trying
>>>>> to better understand the rmap code, looking to see if there's a
>>>>> way to have try_to_unmap_file() work similarly to
>>>>> try_to_unmap_anon(), to allow allow users to madvise() on mmapped
>>>>> tmpfs files. This would provide a very similar interface as to
>>>>> what I've been proposing with fadvise/fallocate, but just using
>>>>> process virtual addresses instead of (fd, offset) pairs.   The
>>>>> benefit with (fd,offset) pairs for Android is that its easier to
>>>>> manage shared volatile ranges between two processes that are
>>>>> sharing data via an mmapped tmpfs file (although this actual use
>>>>> case may be fairly rare).  I believe we should still be able to
>>>>> rework the ashmem internals to use madvise (which would provide
>>>>> legacy support for existing android apps), so then its just a
>>>>> question of if we could then eventually convince Android apps to
>>>>> use the madvise interface directly, rather then the ashmem unpin
>>>>> ioctl.
>>>> Hey Minchan,
>>>>      I've been playing around with your patch trying to better
>>>> understand your approach and to extend it to support tmpfs files. In
>>>> doing so I've found a few bugs, and have some rough fixes I wanted
>>>> to share. There's still a few edge cases I need to deal with (the
>>>> vma-purged flag isn't being properly handled through vma merge/split
>>>> operations), but its starting to come along.
>>> Hmm, my patch doesn't allow to merge volatile with another one by
>>> inserting VM_VOLATILE into VM_SPECIAL so I guess merge isn't problem.
>>> In case of split, __split_vma copy old vma to new vma like this
>>>
>>>          *new = *vma;
>>>
>>> So the problem shouldn't happen, I guess.
>>> Did you see the real problem about that?
>> Yes, depending on the pattern that MADV_VOLATILE and MADV_NOVOLATILE
>> is applied, we can get a result where data is purged, but we aren't
>> notified of it.  Also, since madvise returns early if it encounters
>> an error, in the case where you have checkerboard volatile regions
>> (say every other page is volatile), which you mark non-volatile with
>> one large MADV_NOVOLATILE call, the first volatile vma will be
>> marked non-volatile, but since it returns purged, the madvise loop
>> will stop and the following volatile regions will be left volatile.
>>
>> The patches in the git tree below which handle the perged state
>> better seem to work for my tests, as far as resolving any
>> overlapping calls. Of course there may yet still be problems I've
>> not found.
>>
>>>> Anyway, take a look at the tree here and let me know what you think.
>>>> http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/minchan-anonvol
>> Eager to hear what you think!
> Below two patches look good to me.
>
> [rmap: Simplify volatility checking by moving it out of try_to_unmap_one]
> [rmap: ClearPageDirty() when returning SWAP_DISCARD]
>
> [madvise: Fix NOVOLATILE bug]
> I can't understand description of the patch.
> Could you elaborate it with example?
The case I ran into here is if you have a range where you mark every 
other page as volatile. Then mark all the pages in that range as 
non-volatile in one madvise call.

sys_madvise() will then find the first vma in the range, and call 
madvise_vma(), which marks the first vma non-volatile and return the 
purged state.  If the page has been purged, sys_madvise code will note 
that as an error, and break out of the vma iteration loop, leaving the 
following vmas in the range volatile.

> [madvise: Fixup vma->purged handling]
> I included VM_VOLATILE into VM_SPECIAL intentionally.
> If comment of VM_SPECIAL is right, merge with volatile vmas shouldn't happen.
> So I guess you see other problem. When I see my source code today, locking
> scheme/purge handling is totally broken. I will look at it. Maybe you are seeing
> bug related that. Part of patch is needed. It could be separate patch.
> I will merge it.
I don't think the problem is when vmas being marked VM_VOLATILE are 
being merged, its that when we mark the vma as *non-volatile*, and 
remove the VM_VOLATILE flag we merge the non-volatile vmas with 
neighboring vmas. So preserving the purged flag during that merge is 
important. Again, the example I used to trigger this was an alternating 
pattern of volatile and non volatile vmas, then marking the entire range 
non-volatile (though sometimes in two overlapping passes).

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
