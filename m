From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Wed, 25 Jan 2006 18:16:14 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601251648.58670.raybry@mpdtxmail.amd.com>
 <F6EF7D7093D441B7655A8755@[10.1.1.4]>
In-Reply-To: <F6EF7D7093D441B7655A8755@[10.1.1.4]>
MIME-Version: 1.0
Message-ID: <200601251816.15037.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave,

Here's another one to keep you awake at night:

mmap a shared, anonymous region of 8MB (2MB aligned), and fork off some 
children (4 is good enough for me).    In each child, munmap() a 2 MB portion 
of the shared region (starting at offset 2MB in the shared region) and then 
mmap() a private, anonymous region in its place.   Have each child store some 
unique data in that region, sleep for a bit and then go look to see if its 
data is still there.

Under 2.6.15, this works just fine.   Under 2.6.15 + shpt patch, each child 
still points at the shared region and steps on the data of the other 
children.

I imagine the above gets even more interesting if the offset or length of the 
unmapped region is not a multiple of the 2MB alignment.

All of these test cases are for Opteron.   Your alignment may vary.

(Sorry about this... )

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
