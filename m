Message-ID: <4790570E.80709@google.com>
Date: Thu, 17 Jan 2008 23:36:46 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: [patch] Converting writeback linked lists to a tree based data
 structure
References: <20080115080921.70E3810653@localhost> <1200386774.15103.20.camel@twins> <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com> <400452490.28636@ustc.edu.cn> <20080115194415.64ba95f2.akpm@linux-foundation.org> <400457571.32162@ustc.edu.cn> <20080115204236.6349ac48.akpm@linux-foundation.org> <400459376.04290@ustc.edu.cn> <20080115215149.a881efff.akpm@linux-foundation.org> <400474447.19383@ustc.edu.cn>
In-Reply-To: <400474447.19383@ustc.edu.cn>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fengguang Wu wrote:
> On Tue, Jan 15, 2008 at 09:51:49PM -0800, Andrew Morton wrote:
>> On Wed, 16 Jan 2008 12:55:07 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
>>
>>> On Tue, Jan 15, 2008 at 08:42:36PM -0800, Andrew Morton wrote:
>>>> On Wed, 16 Jan 2008 12:25:53 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
>>>>
>>>>> list_heads are OK if we use them for one and only function.
>>>> Not really.  They're inappropriate when you wish to remember your
>>>> position in the list while you dropped the lock (as we must do in
>>>> writeback).
>>>>
>>>> A data structure which permits us to interate across the search key rather
>>>> than across the actual storage locations is more appropriate.
>>> I totally agree with you. What I mean is to first do the split of
>>> functions - into three: ordering, starvation prevention, and blockade
>>> waiting.
>> Does "ordering" here refer to ordering bt time-of-first-dirty?
> 
> Ordering by dirtied_when or i_ino, either is OK.
> 
>> What is "blockade waiting"?
> 
> Some inodes/pages cannot be synced now for some reason and should be
> retried after a while.
> 
>>> Then to do better ordering by adopting radix tree(or rbtree
>>> if radix tree is not enough),
>> ordering of what?
> 
> Switch from time to location.
> 

Given the way LBAs are located on disk and the fact that rotational 
latency is a large factor in changing locations of a drive head, any 
attempts to do a C-SCAN pass are pretty much useless.  Further 
complicating this is any volume management that sits between the fs and 
the actual storage.

A nice feature to have longer term is to have the write_inodes paths for 
background flushing understand storage congestion _through_ any volume 
management. This would allow us to back off background flushing on a per 
spindle basis (when using drives of course) and avoid write congestion 
in both the io scheduler and in the drive's writecaches, which I 
believe, but don't have hard evidence, get congested today, knocking the 
drive into a fifo fashion in firmware.

A data structure that allows us to keep a dirtied_when values consistent 
across back-offs and blocking allows us to further develop the 
background writeout paths to get to this point (though exposing this 
congestion information will require more work deeper in the stack).

>>> and lastly get rid of the list_heads to
>>> avoid locking. Does it sound like a good path?
>> I'd have thaought that replacing list_heads with another data structure
>> would be a simgle commit.
> 
> That would be easy. s_more_io and s_more_io_wait can all be converted
> to radix trees.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
