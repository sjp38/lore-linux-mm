Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18542
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 18:21:16 -0400
Date: Wed, 7 Apr 1999 00:19:36 +0200 (CEST)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <14090.31508.740918.361855@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990406234420.22306A-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Stephen C. Tweedie wrote:

-#define i (((unsigned long) inode)/(sizeof(struct inode) \
		 & ~ (sizeof(struct inode) - 1)))
+#define i (((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) \
		 & ~ (sizeof(struct inode) - 1)))

> This just ends up adding or subtracting a constant to the hash function,
> so won't have any effect at all on the occupancy distribution of the
> hash buckets.

btw. shouldnt it rather be something like: 

#define log2(x) \
({                                                              \
        int __res;                                              \
                                                                \
        switch (x) {                                            \
                case 0x040 ... 0x07f: __res = 0x040; break;     \
                case 0x080 ... 0x0ff: __res = 0x080; break;     \
                case 0x100 ... 0x1ff: __res = 0x100; break;     \
                case 0x200 ... 0x3ff: __res = 0x200; break;     \
                case 0x400 ... 0x7ff: __res = 0x400; break;     \
                case 0x800 ... 0xfff: __res = 0x800; break;     \
        }                                                       \
        __res;                                                  \
})

#define i (((unsigned long) inode)/log2(sizeof(struct inode)))

because otherwise we 'over-estimate' and include systematic bits in the
supposedly random index. Eg. in 2.2.5 the size of struct inode is 0x110,
which means 'i' will have values 0x11, 0x22, 0x33, for inodes within the
same page. (we'd preferably have i == 0x01, 0x02, 0x03...)

the hash was designed when struct inode has a size of 512 i think, for
which the original #define was correct. But for 0x110 it isnt IMHO. (my
above macros produce i==0,1,2...0xf iterated over inode addresses within
the same physical page.) 

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
