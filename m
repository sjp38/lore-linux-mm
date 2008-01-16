Message-ID: <478E6AFD.1020302@cosmosbay.com>
Date: Wed, 16 Jan 2008 21:37:17 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] x86: Change size of node ids from u8 to u16 V3
References: <20080116170902.006151000@sgi.com>	<20080116170902.328187000@sgi.com> <20080116185356.e8d02344.dada1@cosmosbay.com> <478E57F2.8010206@sgi.com>
In-Reply-To: <478E57F2.8010206@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mike Travis a ecrit :
>> Another point: you want this change, sorry if my previous mail was not detailed enough :
>>
>> --- a/arch/x86/mm/numa_64.c
>> +++ b/arch/x86/mm/numa_64.c
>> @@ -78,7 +78,7 @@ static int __init allocate_cachealigned_memnodemap(void)
>>         unsigned long pad, pad_addr;
>>
>>         memnodemap = memnode.embedded_map;
>> -       if (memnodemapsize <= 48)
>> +       if (memnodemapsize <= ARRAY_SIZE(memnode.embedded_map))
>>                 return 0;
>>
>>         pad = L1_CACHE_BYTES - 1;
>>
> 
> Hi Eric,
> 
> I'm still getting this message with the numa=fake=4 start option:
> 
> Faking node 0 at 0000000000000000-0000000028000000 (640MB)
> Faking node 1 at 0000000028000000-0000000050000000 (640MB)
> Faking node 2 at 0000000050000000-0000000078000000 (640MB)
> Faking node 3 at 0000000078000000-000000009ff00000 (639MB)
> 
> NUMA: Using 27 for the hash shift.
> Your memory is not aligned you need to rebuild your kernel
> with a bigger NODEMAPSIZE shift=27 No NUMA hash function found.
> NUMA emulation disabled.
> 
> Is there something else I need to change?  (This is on an AMD box.)
> 

Sure, check populate_memnodemap() in arch/x86/mm/numa_64.c


--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -54,7 +54,7 @@ populate_memnodemap(const struct bootnode *nodes, int 
numnodes, int shift)
         int res = -1;
         unsigned long addr, end;

-       memset(memnodemap, 0xff, memnodemapsize);
+       memset(memnodemap, 0xff, sizeof(u16)*memnodemapsize);
         for (i = 0; i < numnodes; i++) {
                 addr = nodes[i].start;
                 end = nodes[i].end;
@@ -63,7 +63,7 @@ populate_memnodemap(const struct bootnode *nodes, int 
numnodes, int shift)
                 if ((end >> shift) >= memnodemapsize)
                         return 0;
                 do {
-                       if (memnodemap[addr >> shift] != 0xff)
+                       if (memnodemap[addr >> shift] != NUMA_NO_NODE)
                                 return -1;
                         memnodemap[addr >> shift] = i;
                         addr += (1UL << shift);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
