Message-ID: <467F67A8.3030408@yahoo.com.au>
Date: Mon, 25 Jun 2007 16:58:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] fsblock
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org> <20070624034755.GA3292@wotan.suse.de> <20070624135126.GA10077@think.oraclecorp.com>
In-Reply-To: <20070624135126.GA10077@think.oraclecorp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Jeff Garzik <jeff@garzik.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Sun, Jun 24, 2007 at 05:47:55AM +0200, Nick Piggin wrote:

>>>My gut feeling is that there are several problem areas you haven't hit 
>>>yet, with the new code.
>>
>>I would agree with your gut :)
>>
> 
> 
> Without having read the code yet (light reading for monday morning ;),
> ext3 and reiserfs use buffers heads for data=ordered to help them do
> deadlock free writeback.  Basically they need to be able to write out
> the pending data=ordered pages, potentially with the transaction lock
> held (or if not held, while blocking new transactions from starting).
> 
> But, writepage, prepare_write and commit_write all need to start a
> transaction with the page lock already held.  So, if the page lock were
> used for data=ordered writeback, there would be a lock inversion between
> the transaction lock and the page lock.

Ah, thanks for that information.


> Using buffer heads instead allows the FS to send file data down inside
> the transaction code, without taking the page lock.  So, locking wrt
> data=ordered is definitely going to be tricky.
> 
> The best long term option may be making the locking order
> transaction -> page lock, and change writepage to punt to some other
> queue when it needs to start a transaction.

Yeah, that's what I would like, and I think it would come naturally
if we move away from these "pass down a single, locked page APIs"
in the VM, and let the filesystem do the locking and potentially
batching of larger ranges.

write_begin/write_end is a step in that direction (and it helps
OCFS and GFS quite a bit). I think there is also not much reason
for writepage sites to require the page to lock the page and clear
the dirty bit themselves (which has seems ugly to me).

So yes, I definitely want to move the aops API along with fsblock.

That I have tried to keep it within the existing API for the moment
is just because that makes things a bit easier...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
