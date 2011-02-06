Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7A48D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 10:13:19 -0500 (EST)
Date: Sun, 06 Feb 2011 10:13:41 -0500
Subject: Re: [LSF/MM TOPIC] Writeback - current state and future
From: "Sorin Faibish" <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
MIME-Version: 1.0
References: <20110204164222.GG4104@quack.suse.cz>
 <4D4E7B48.9020500@panasas.com>
Content-Transfer-Encoding: 8bit
Message-ID: <op.vqhlw3rirwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <4D4E7B48.9020500@panasas.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <bharrosh@panasas.com>, Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>

I was thinking to have a special track for all the writeback related  
topics.
I would like also to include a discussion on new cache writeback paterns
with the target to prevent any cache swaps that are becoming a bigger  
problem
when dealing with servers wir 100's GB caches. The swap is the worst that
could happen to the performance of such systems. I will share my latest  
findings
in the cache writeback in continuation to my previous discussion at last  
LSF.

/Sorin

On Sun, 06 Feb 2011 05:43:20 -0500, Boaz Harrosh <bharrosh@panasas.com>  
wrote:

> On 02/04/2011 06:42 PM, Jan Kara wrote:
>>   Hi,
>>
>>   I'd like to have one session about writeback. The content would highly
>> depend on the current state of things but on a general level, I'd like  
>> to
>> quickly sum up what went into the kernel (or is mostly ready to go)  
>> since
>> last LSF (handling of background writeback, livelock avoidance), what is
>> being worked on - IO-less balance_dirty_pages() (if it won't be in the
>> mostly done section), what other things need to be improved (kswapd
>> writeout, writeback_inodes_sb_if_idle() mess, come to my mind now)
>>
>> 								Honza
>
> Ha, I most certainly want to participate in this talk. I wanted to
> suggest it myself.
>
> Topics that I would like to raise on the matter.
>
> [IO-less balance_dirty_pages]
> As said, I'd really like if Wu or Jan could explain more about the math
> and IO patterns that went into this tremendous work, and how it should
> affect us fs maintainers in means of advantages and disadvantages. If
> digging too deeply into this is not interesting for every body, perhaps
> a side meeting with fewer people is also possible.
>
> [Aligned write-back]
> I have just finished raid5/6 support in my filesystem and will be sending
> a patch that tries very aggressively to align IO on stripe boundaries.
> I did not take the btrfs way of cut/paste of the write_cache_pages()  
> function
> to better fit the bill. I used the wbc->nr_to_write to trim down IO on  
> stripe
> alignment. Together with some internal structure games, I now have a much
> better situation then untouched code. Better I mean that if I have simple
> linear dd IO on a file, I can see o(90%) aligned IOs as opposed to 20%  
> before
> that patch. The only remaining issue, I think I have not fully  
> investigated
> it yet, is that: because I do not want any residues left from outside the
> writepages() call so I do not need to sync and lock with flush, and have  
> a
> "flushing" flag in my writeout path. So what I still get is that  
> sometimes
> the writeback is able to catch up with dd and I get short writes at the
> reminder, which makes the end of this call and the start of the next call
> unaligned.
>
> I envision a simple BDI members just like ra_pages for readahead that  
> better
> govern the writeback chunking. (And is accounted for in the fairness).
>
> [Smarter/more cache eviction patterns]
> I love it when I do a simple dd test in a UML (300Mg of ram) and half  
> way down
> I get these fat WARN_ONs of the iscsi tcp writeback failing to allocate  
> network
> buffers. And I did lower the writeback ratio a lot because the default  
> of 20% does
> not work for a long time, like since 35 or 36. The UML is not the only  
> affected
> system any low-memory embedded-like but 64 bit system would be. Now the  
> IO does
> complete eventually but the performance is down to 20%.
>
> Now for a dd or cp like work pattern I would like the pages be freed  
> much more
> aggressively, like right after IO completion because I most certainly  
> will not
> use them again. On the other side git for example will write a big  
> sequential
> file then immediately turn and read it, so cache presence is a win. But  
> I think
> we can still come up with good patterns that take into account the  
> number of
> fileh opened on an inode, and some hot inode history to come up with  
> better
> patterns. (Some of this history we already have with the security  
> plugins)
>
> And there are other topics that I had, but can remember right now.
>
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Best Regards
Sorin Faibish
Corporate Distinguished Engineer
Unified Storage Division

        EMC2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
