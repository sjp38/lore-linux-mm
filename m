Date: Wed, 27 Jul 2005 01:29:44 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
Message-Id: <20050727012944.6ce7bb9a.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.58.0507181328480.2899@skynet>
References: <1121101013.15095.19.camel@localhost>
	<42D2AE0F.8020809@austin.ibm.com>
	<20050711195540.681182d0.pj@sgi.com>
	<Pine.LNX.4.58.0507121353470.32323@skynet>
	<20050712132940.148a9490.pj@sgi.com>
	<Pine.LNX.4.58.0507130815420.1174@skynet>
	<20050714040613.10b244ee.pj@sgi.com>
	<Pine.LNX.4.58.0507181328480.2899@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel wrote:
> That makes sense to me. Taking into account other threads, attached are
> patches 01 and 02 from Joels patchset with the different namings and
> comments. The main changes are the renaming of __GFP_USERRCLM to
> __GFP_USER to be neutral and comments explaining how the RCLM flags are
> tied together.

Ok - gaining.

One thing still confuses me here.  What would it mean to have a gfp
flag with both (__GFP_USER|__GFP_KERNRCLM) bits set?  Is this a valid
gfp flag, or is it just in pfn's that both bits can be set (meaning
FALLBACK)?

If both bits can be set at the same time in a gfp flag, then I don't
think either of the following two comments are accurate:

+#define __GFP_USER     0x40000u /* Easily reclaimable userspace page */
+#define __GFP_KERNRCLM 0x80000u /* Kernel page that is easily reclaimable */

Just looking at the GFP_USER bit and seeing it is set doesn't tell me
for sure it's a userspace page request.  It might be a reclaimable
kernel page that we had to fallback on, right?  Similarly for the
__GFP_KERNRCLM bit.

And if both bits can be set in a gfp flag at the same time, then the
test that _I_ need, for my two flavors of cpuset allocation is not
possible, because I need to distinguish FALLBACK allocations for
USER space requests from FALLBACK allocations for KERNEL space
requests (USER space memory placement is confined more tightly).

Continuing this line of inquiry, what does it mean if neither bit
is set in a gfp flag?  I guess that's a valid gfp flag, and it means
that the request is for non-reclaimable kernel memory.  Is that
right?  If so, fine and this detail doesn't impact my intended use.

But the overloading of both bits set to mean FALLBACK, in the gfp
flag, if that's what you intend here, does seem to make the apparent
flagging userspace requests useless to my purposes, because I want
to treat userspace FALLBACK requests differently than kernelspace
FALLBACKs.  For me, they are still userspace and kernel space.  For
you, they are both FALLBACKs.  If my train of thought here hasn't
gone off the rails, this would mean that I would still need my own
GFP USER flag, and that I would encourage you to reinstate the
RCLM tag on your __GFP_USER* flag, to distinguish it from mine.
That, or perhaps it works to _not_ encode the fallback case in the
gfp flags using the USER|KERN bits both set, but rather have a
separate bit for the FALLBACK case.  I can appreciate that in pfn's
you have to encode this tightly for performance, but I'd be surprised
if you have to do so in gfp flags for performance.

And in any case, the assymmetry of the __GFP_USER and __GFP_KERNRCLM
names is a wart - one gets the RCLM tag and one doesn't.  And the
comment above for __GFP_USER still reflects solely the reclaim use
of this bit, not a more neutral use.

... Please don't send patches as base64 encodings of carriage
return terminated lines.  Patches should be plain text inline,
or at most plain text attachments.  In either case, they should
have newline terminated lines.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
