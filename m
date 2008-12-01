Date: Mon, 1 Dec 2008 12:26:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081201112609.GC13903@wotan.suse.de>
References: <20081201083343.GC2529@wotan.suse.de> <87ljv05ezr.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ljv05ezr.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 12:09:12PM +0100, Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> > Hi,
> > Comments?
> > Thanks,
> > Nick
> >
> > --
> > struct dentry is one of the most critical structures in the kernel. So it's
> > sad to see it going neglected.
> 
> Very nice. But the sad thing is that such optimizations tend to quickly
> bit rot again. At least add big fat comments.

I was tempted to add a "Don't add anything to struct dentry" comment :)


> How does it look like on 32bit hosts?

Actually 32bit does not gain anything from packing d_mounted, but it
does benefit from removing d_cookie, so in that case I just added
another 4 bytes to the inline name length in order to keep it at 128
bytes.

Removing the CONFIG_PROFILING difference is quite nice because the
last thing you want is to try to profile something in the dcache and
find that cache access characteristics change when you enable
oprofile :P


> Since the size is variable depending on word size it might be a 
> good idea to auto adjust inline name length to always give a nice
> end result for slab.

Yeah, well I didn't auto adjust, but I took care to try to make it
good values on each platform.
 

> Also I think with some effort it would be possible to shrink it more.
> But since you already reached cache lines, it would just allow
> to increase inline name length. Ok perhaps it would help more on 32bit.
> 
> Further possibilities to shrink: 
> - Eliminate name.length. It seems of dubious utility
> (in general I'm not sure struct qstr is all that useful)
> - Change some of the children/alias list_heads to hlist_heads. I don't
> think these lists typically need O(1) access to the end.
> - If the maximum mount nest was limited d_mounted could migrate
> into d_flags (that would be probably desparate)

Yeah, well it would always be nice to add more bytes to the name
length... CONFIG_TINY would probably not care about reaching cache
line sizes either, so small systems I'm sure would like to see
savings.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
