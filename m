Subject: Re: [patch][rfc] fs: shrink struct dentry
From: Andi Kleen <andi@firstfloor.org>
References: <20081201083343.GC2529@wotan.suse.de>
Date: Mon, 01 Dec 2008 12:09:12 +0100
In-Reply-To: <20081201083343.GC2529@wotan.suse.de> (Nick Piggin's message of "Mon, 1 Dec 2008 09:33:43 +0100")
Message-ID: <87ljv05ezr.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

> Hi,
> Comments?
> Thanks,
> Nick
>
> --
> struct dentry is one of the most critical structures in the kernel. So it's
> sad to see it going neglected.

Very nice. But the sad thing is that such optimizations tend to quickly
bit rot again. At least add big fat comments.

How does it look like on 32bit hosts?

Since the size is variable depending on word size it might be a 
good idea to auto adjust inline name length to always give a nice
end result for slab.

Also I think with some effort it would be possible to shrink it more.
But since you already reached cache lines, it would just allow
to increase inline name length. Ok perhaps it would help more on 32bit.

Further possibilities to shrink: 
- Eliminate name.length. It seems of dubious utility
(in general I'm not sure struct qstr is all that useful)
- Change some of the children/alias list_heads to hlist_heads. I don't
think these lists typically need O(1) access to the end.
- If the maximum mount nest was limited d_mounted could migrate
into d_flags (that would be probably desparate)

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
