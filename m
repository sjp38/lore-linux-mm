Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1A31831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 02:17:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p86so116614527pfl.12
        for <linux-mm@kvack.org>; Sun, 21 May 2017 23:17:58 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id b76si16301470pfd.382.2017.05.21.23.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 May 2017 23:17:57 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
In-Reply-To: <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com> <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
Date: Mon, 22 May 2017 16:17:54 +1000
Message-ID: <87inkts9d9.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

Pavel Tatashin <pasha.tatashin@oracle.com> writes:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8afa63e81e73..15bba5c325a5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7169,6 +7169,17 @@ static unsigned long __init arch_reserved_kernel_pages(void)
>  #endif
>  
>  /*
> + * Adaptive scale is meant to reduce sizes of hash tables on large memory
> + * machines. As memory size is increased the scale is also increased but at
> + * slower pace.  Starting from ADAPT_SCALE_BASE (64G), every time memory
> + * quadruples the scale is increased by one, which means the size of hash table
> + * only doubles, instead of quadrupling as well.
> + */
> +#define ADAPT_SCALE_BASE	(64ull << 30)
> +#define ADAPT_SCALE_SHIFT	2
> +#define ADAPT_SCALE_NPAGES	(ADAPT_SCALE_BASE >> PAGE_SHIFT)
> +
> +/*
>   * allocate a large system hash table from bootmem
>   * - it is assumed that the hash table must contain an exact power-of-2
>   *   quantity of entries
> @@ -7199,6 +7210,14 @@ void *__init alloc_large_system_hash(const char *tablename,
>  		if (PAGE_SHIFT < 20)
>  			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
>  
> +		if (!high_limit) {
> +			unsigned long long adapt;
> +
> +			for (adapt = ADAPT_SCALE_NPAGES; adapt < numentries;
> +			     adapt <<= ADAPT_SCALE_SHIFT)
> +				scale++;
> +		}

This still doesn't work for me. The scale++ is overflowing according to
UBSAN (line 7221).

It looks like numentries is 194560.

00000950  68 0a 50 49 44 20 68 61  73 68 20 74 61 62 6c 65  |h.PID hash table|
00000960  20 65 6e 74 72 69 65 73  3a 20 34 30 39 36 20 28  | entries: 4096 (|
00000970  6f 72 64 65 72 3a 20 32  2c 20 31 36 33 38 34 20  |order: 2, 16384 |
00000980  62 79 74 65 73 29 0a 61  6c 6c 6f 63 5f 6c 61 72  |bytes).alloc_lar|
00000990  67 65 5f 73 79 73 74 65  6d 5f 68 61 73 68 3a 20  |ge_system_hash: |
000009a0  6e 75 6d 65 6e 74 72 69  65 73 20 31 39 34 35 36  |numentries 19456|
000009b0  30 0a 61 6c 6c 6f 63 5f  6c 61 72 67 65 5f 73 79  |0.alloc_large_sy|
000009c0  73 74 65 6d 5f 68 61 73  68 3a 20 61 64 61 70 74  |stem_hash: adapt|
000009d0  20 30 0a 3d 3d 3d 3d 3d  3d 3d 3d 3d 3d 3d 3d 3d  | 0.=============|
000009e0  3d 3d 3d 3d 3d 3d 3d 3d  3d 3d 3d 3d 3d 3d 3d 3d  |================|
*
00000a20  3d 3d 3d 0a 55 42 53 41  4e 3a 20 55 6e 64 65 66  |===.UBSAN: Undef|
00000a30  69 6e 65 64 20 62 65 68  61 76 69 6f 75 72 20 69  |ined behaviour i|
00000a40  6e 20 2e 2e 2f 6d 6d 2f  70 61 67 65 5f 61 6c 6c  |n ../mm/page_all|
00000a50  6f 63 2e 63 3a 37 32 32  31 3a 31 30 0a 73 69 67  |oc.c:7221:10.sig|
00000a60  6e 65 64 20 69 6e 74 65  67 65 72 20 6f 76 65 72  |ned integer over|
00000a70  66 6c 6f 77 3a 0a 32 31  34 37 34 38 33 36 34 37  |flow:.2147483647|
00000a80  20 2b 20 31 20 63 61 6e  6e 6f 74 20 62 65 20 72  | + 1 cannot be r|
00000a90  65 70 72 65 73 65 6e 74  65 64 20 69 6e 20 74 79  |epresented in ty|
00000aa0  70 65 20 27 69 6e 74 20  5b 34 5d 27 0a 43 50 55  |pe 'int [4]'.CPU|
00000ab0  3a 20 30 20 50 49 44 3a  20 30 20 43 6f 6d 6d 3a  |: 0 PID: 0 Comm:|
00000ac0  20 73 77 61 70 70 65 72  20 4e 6f 74 20 74 61 69  | swapper Not tai|
00000ad0  6e 74 65 64 20 34 2e 31  32 2e 30 2d 72 63 31 2d  |nted 4.12.0-rc1-|
00000ae0  67 63 63 2d 36 2e 33 2e  31 2d 30 30 31 38 32 2d  |gcc-6.3.1-00182-|
00000af0  67 36 37 64 30 36 38 37  32 32 34 61 39 2d 64 69  |g67d0687224a9-di|
00000b00  72 74 79 20 23 38 0a 43  61 6c 6c 20 54 72 61 63  |rty #8.Call Trac|
00000b10  65 3a 0a 5b 63 30 65 30  35 65 61 30 5d 20 5b 63  |e:.[c0e05ea0] [c|
00000b20  30 34 37 38 38 63 34 5d  20 75 62 73 61 6e 5f 65  |04788c4] ubsan_e|
00000b30  70 69 6c 6f 67 75 65 2b  30 78 31 38 2f 30 78 34  |pilogue+0x18/0x4|
00000b40  63 20 28 75 6e 72 65 6c  69 61 62 6c 65 29 0a 5b  |c (unreliable).[|
00000b50  63 30 65 30 35 65 62 30  5d 20 5b 63 30 34 37 39  |c0e05eb0] [c0479|
00000b60  32 36 30 5d 20 68 61 6e  64 6c 65 5f 6f 76 65 72  |260] handle_over|
00000b70  66 6c 6f 77 2b 30 78 62  63 2f 30 78 64 63 0a 5b  |flow+0xbc/0xdc.[|
00000b80  63 30 65 30 35 66 33 30  5d 20 5b 63 30 61 62 39  |c0e05f30] [c0ab9|
00000b90  38 66 38 5d 20 61 6c 6c  6f 63 5f 6c 61 72 67 65  |8f8] alloc_large|
00000ba0  5f 73 79 73 74 65 6d 5f  68 61 73 68 2b 30 78 65  |_system_hash+0xe|
00000bb0  34 2f 30 78 35 65 63 0a  5b 63 30 65 30 35 66 39  |4/0x5ec.[c0e05f9|
00000bc0  30 5d 20 5b 63 30 61 62  65 30 30 30 5d 20 76 66  |0] [c0abe000] vf|
00000bd0  73 5f 63 61 63 68 65 73  5f 69 6e 69 74 5f 65 61  |s_caches_init_ea|
00000be0  72 6c 79 2b 30 78 34 63  2f 30 78 36 34 0a 5b 63  |rly+0x4c/0x64.[c|
00000bf0  30 65 30 35 66 62 30 5d  20 5b 63 30 61 61 35 32  |0e05fb0] [c0aa52|
00000c00  31 38 5d 20 73 74 61 72  74 5f 6b 65 72 6e 65 6c  |18] start_kernel|
00000c10  2b 30 78 32 33 63 2f 30  78 33 63 34 0a 5b 63 30  |+0x23c/0x3c4.[c0|
00000c20  65 30 35 66 66 30 5d 20  5b 30 30 30 30 33 34 34  |e05ff0] [0000344|
00000c30  63 5d 20 30 78 33 34 34  63 0a 3d 3d 3d 3d 3d 3d  |c] 0x344c.======|
00000c40  3d 3d 3d 3d 3d 3d 3d 3d  3d 3d 3d 3d 3d 3d 3d 3d  |================|

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
