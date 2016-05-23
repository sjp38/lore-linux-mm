Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB706B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 02:47:53 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id l5so6554260obw.0
        for <linux-mm@kvack.org>; Sun, 22 May 2016 23:47:53 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id z12si5424876ioi.145.2016.05.22.23.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 May 2016 23:47:52 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id p81so3505477itd.3
        for <linux-mm@kvack.org>; Sun, 22 May 2016 23:47:52 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 23 May 2016 14:47:51 +0800
Message-ID: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
Subject: page order 0 allocation fail but free pages are enough
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: multipart/mixed; boundary=001a11419becc9fc3b05337cd10b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11419becc9fc3b05337cd10b
Content-Type: text/plain; charset=UTF-8

hi all:
I got something wired that
1. in softirq, there is a page order 0 allocation request
2. Normal/High zone are free enough for order 0 page.
3. but somehow kernel return order 0 allocation fail.

My kernel version is 3.10 and below is kernel log:
from memory info,
the usd of pcb in Norma/High is > 0
[ 8606.703526] Mem-info:
[ 8606.703530] Normal per-cpu:
[ 8606.703535] CPU    0: hi:   90, btch:  15 usd:  10
[ 8606.703540] CPU    1: hi:   90, btch:  15 usd:  47
[ 8606.703543] HighMem per-cpu:
[ 8606.703547] CPU    0: hi:   18, btch:   3 usd:   2
[ 8606.703551] CPU    1: hi:   18, btch:   3 usd:   2

the free memory size of Normal is
[ 8606.703590] Normal free:60684kB

the free memory size of Highmem is
[ 8606.703625] HighMem free:300kB

I trace mm/page_alloc.c the page order 0 allocation will follow below path.
a. if pcp->count !=0, the page will directly get from pre-allocated list.
b. if pcp->count ==0, the page will allocated from budy system if it
is still get free pages enough.

in my case, both a) and b) the page allocation should be ok.
But why kernel still reject the order 0 page allocation?
appreciate your kind help in advance,

    get_page_from_freelist --> buffered_rmqueue -->
               if (likely(order == 0)) {
                struct per_cpu_pages *pcp;
                struct list_head *list;

                local_irq_save(flags);
                pcp = &this_cpu_ptr(zone->pageset)->pcp;
                list = &pcp->lists[migratetype];
                if (list_empty(list)) {
                        pcp->count += rmqueue_bulk(zone, 0,
                                        pcp->batch, list,
                                        migratetype, cold);
                        if (unlikely(list_empty(list)))
                                goto failed;
                }
                if (cold)
                        page = list_entry(list->prev, struct page, lru);
                else
                        page = list_entry(list->next, struct page, lru);
                list_del(&page->lru);
                pcp->count--;


[ 8606.701343] CompositorTileW: page allocation failure: order:0, mode:0x20
[ 8606.701356] CPU: 0 PID: 26064 Comm: CompositorTileW Tainted: G
     O 3.10.0+ #2
[ 8606.701365] Backtrace:
[ 8606.701390] [<c00129f8>] (dump_backtrace+0x0/0x114) from
[<c0012c68>] (show_stack+0x20/0x24)
[ 8606.701403]  r6:c9bee000 r5:00000000 r4:00000020 r3:271ae71c
[ 8606.701419] [<c0012c48>] (show_stack+0x0/0x24) from [<c056d2ec>]
(dump_stack+0x24/0x28)
[ 8606.701434] [<c056d2c8>] (dump_stack+0x0/0x28) from [<c010c668>]
(warn_alloc_failed+0xec/0x128)
[ 8606.701447] [<c010c57c>] (warn_alloc_failed+0x0/0x128) from
[<c010fd1c>] (__alloc_pages_nodemask+0x70c/0x940)
[ 8606.701456]  r3:00000000 r2:00000000
[ 8606.701466]  r7:c07fe240 r6:00000000 r5:00000000 r4:00000020
[ 8606.701476] [<c010f610>] (__alloc_pages_nodemask+0x0/0x940) from
[<c043ebc4>] (__netdev_alloc_frag+0x1cc/0x1e8)
[ 8606.701487] [<c043e9f8>] (__netdev_alloc_frag+0x0/0x1e8) from
[<c044128c>] (__netdev_alloc_skb+0x84/0xe0)
[ 8606.701943] [<c0441208>] (__netdev_alloc_skb+0x0/0xe0) from
[<bfbf834c>] (_rtw_skb_alloc+0x3c/0x40 [8812au])
[ 8606.701958]  r6:0000060e r5:d4af3160 r4:0000064a r3:00000100
[ 8606.702374] [<bfbf8310>] (_rtw_skb_alloc+0x0/0x40 [8812au]) from
[<bfc0bc80>] (rtw_os_alloc_recvframe+0x6c/0xfc [8812au])
[ 8606.702795] [<bfc0bc14>] (rtw_os_alloc_recvframe+0x0/0xfc [8812au])
from [<bfc4eb64>] (recvbuf2recvframe+0x36c/0x388 [8812au])
[ 8606.703193] [<bfc4e7f8>] (recvbuf2recvframe+0x0/0x388 [8812au])
from [<bfbff438>] (usb_recv_tasklet+0x6c/0x94 [8812au])
[ 8606.703385] [<bfbff3cc>] (usb_recv_tasklet+0x0/0x94 [8812au]) from
[<c002de24>] (tasklet_action+0xa8/0x178)
[ 8606.703398]  r7:c07b25ec r6:00000000 r5:d4809b5c r4:d4809b58
[ 8606.703407] [<c002dd7c>] (tasklet_action+0x0/0x178) from
[<c002cdd0>] (__do_softirq+0x164/0x344)
[ 8606.703423]  r8:00000008 r7:00000018 r6:c07b8098 r5:c9bee000 r4:00000006
[ 8606.703423] r3:c002dd7c
[ 8606.703431] [<c002cc6c>] (__do_softirq+0x0/0x344) from [<c002d530>]
(irq_exit+0xbc/0xf0)
[ 8606.703444] [<c002d474>] (irq_exit+0x0/0xf0) from [<c000eda0>]
(handle_IRQ+0x54/0xa0)
[ 8606.703452]  r5:00000056 r4:c07b3f40
[ 8606.703460] [<c000ed4c>] (handle_IRQ+0x0/0xa0) from [<c0008594>]
(gic_handle_irq+0x3c/0x6c)
[ 8606.703472]  r6:c9beffb0 r5:c07c82cc r4:feffe10c r3:00000000
[ 8606.703483] [<c0008558>] (gic_handle_irq+0x0/0x6c) from
[<c05718e4>] (__irq_usr+0x44/0x60)
[ 8606.703489] Exception stack(0xc9beffb0 to 0xc9befff8)
[ 8606.703495] ffa0:                                     00000001
01581600 20e8fcf6 00000001
[ 8606.703504] ffc0: 00000013 4fb149a0 00000007 ffffffff 00000008
00000001 00000009 01580bc4
[ 8606.703512] ffe0: 0000000c b015afa0 b5de0cb8 b36b74c8 00070170
ffffffff ff121212
[ 8606.703524]  r7:ffffffff r6:ffffffff r5:00070170 r4:b36b74c8
[ 8606.703526] Mem-info:
[ 8606.703530] Normal per-cpu:
[ 8606.703535] CPU    0: hi:   90, btch:  15 usd:  10
[ 8606.703540] CPU    1: hi:   90, btch:  15 usd:  47
[ 8606.703543] HighMem per-cpu:
[ 8606.703547] CPU    0: hi:   18, btch:   3 usd:   2
[ 8606.703551] CPU    1: hi:   18, btch:   3 usd:   2
[ 8606.703564] active_anon:31649 inactive_anon:6232 isolated_anon:0
[ 8606.703564]  active_file:4303 inactive_file:17299 isolated_file:0
[ 8606.703564]  unevictable:0 dirty:146 writeback:0 unstable:0
[ 8606.703564]  free:15246 slab_reclaimable:1469 slab_unreclaimable:6629
[ 8606.703564]  mapped:17380 shmem:6266 pagetables:884 bounce:0
[ 8606.703564]  free_cma:14991
[ 8606.703590] Normal free:60684kB min:2000kB low:2500kB high:3000kB
active_anon:84188kB inactive_anon:24032kB active_file:7632kB
inactive_file:34812kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:329728kB managed:250408kB mlocked:0kB
dirty:568kB writeback:0kB mapped:43124kB shmem:24148kB
slab_reclaimable:5876kB slab_unreclaimable:26516kB kernel_stack:2656kB
pagetables:3536kB unstable:0kB bounce:0kB free_cma:59964kB
writeback_tmp:0kB pages_scanned:68 all_unreclaimable? no
[ 8606.703610] lowmem_reserve[]: 0 696 696
[ 8606.703625] HighMem free:300kB min:128kB low:304kB high:480kB
active_anon:42408kB inactive_anon:896kB active_file:9580kB
inactive_file:34384kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:89088kB managed:89088kB mlocked:0kB
dirty:16kB writeback:0kB mapped:26396kB shmem:916kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB
pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? no
[ 8606.703644] lowmem_reserve[]: 0 0 0
[ 8606.703676] Normal: 1013*4kB (UC) 1013*8kB (UMC) 1013*16kB (UC)
1002*32kB (UC) 4*64kB (U) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB
0*4096kB = 60684kB
[ 8606.703706] HighMem: 3*4kB (M) 2*8kB (R) 1*16kB (R) 0*32kB 0*64kB
0*128kB 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 300kB
[ 8606.703708] 27876 total pagecache pages
[ 8606.703715] 0 pages in swap cache
[ 8606.703719] Swap cache stats: add 0, delete 0, find 0/0
[ 8606.703722] Free swap  = 0kB
[ 8606.703724] Total swap = 0kB
[ 8606.703840] RTL871X: rtw_os_alloc_recvframe:can not allocate memory
for skb copy

--001a11419becc9fc3b05337cd10b
Content-Type: text/plain; charset=US-ASCII; name="page_alloc_fail_pcp_0.txt"
Content-Disposition: attachment; filename="page_alloc_fail_pcp_0.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iojnh2t80

WyAgIDk0LjU4NjU4OF0ga3NvZnRpcnFkLzA6IHBhZ2UgYWxsb2NhdGlvbiBmYWlsdXJlOiBvcmRl
cjowLCBtb2RlOjB4MjAKWyAgIDk0LjU5MjkzNF0gQ1BVOiAwIFBJRDogMyBDb21tOiBrc29mdGly
cWQvMCBUYWludGVkOiBHICAgICAgICAgICBPIDMuMTAuMCsgIzEKWyAgIDk0LjYwMDAzOV0gQmFj
a3RyYWNlOiAKWyAgIDk0LjYwMjUxMl0gWzxjMDAxMjlmOD5dIChkdW1wX2JhY2t0cmFjZSsweDAv
MHgxMTQpIGZyb20gWzxjMDAxMmM2OD5dIChzaG93X3N0YWNrKzB4MjAvMHgyNCkKWyAgIDk0LjYx
MDkxNl0gIHI2OmNmY2I2MDAwIHI1OjAwMDAwMDAwIHI0OjAwMDAwMDIwIHIzOjI3MWFlNzFjClsg
ICA5NC42MTY2MzRdIFs8YzAwMTJjNDg+XSAoc2hvd19zdGFjaysweDAvMHgyNCkgZnJvbSBbPGMw
NTZkMmVjPl0gKGR1bXBfc3RhY2srMHgyNC8weDI4KQpbICAgOTQuNjI0NjEzXSBbPGMwNTZkMmM4
Pl0gKGR1bXBfc3RhY2srMHgwLzB4MjgpIGZyb20gWzxjMDEwYzY2OD5dICh3YXJuX2FsbG9jX2Zh
aWxlZCsweGVjLzB4MTI4KQpbICAgOTQuNjMzMjg1XSBbPGMwMTBjNTdjPl0gKHdhcm5fYWxsb2Nf
ZmFpbGVkKzB4MC8weDEyOCkgZnJvbSBbPGMwMTBmZDFjPl0gKF9fYWxsb2NfcGFnZXNfbm9kZW1h
c2srMHg3MGMvMHg5NDApClsgICA5NC42NDMxNjBdICByMzowMDAwMDAwMCByMjowMDAwMDAwMApb
ICAgOTQuNjQ2NzU0XSAgcjc6YzA3ZmUyNDAgcjY6MDAwMDAwMDAgcjU6MDAwMDAwMDAgcjQ6MDAw
MDAwMjAKWyAgIDk0LjY1MjQ2NV0gWzxjMDEwZjYxMD5dIChfX2FsbG9jX3BhZ2VzX25vZGVtYXNr
KzB4MC8weDk0MCkgZnJvbSBbPGMwNDNlYmM0Pl0gKF9fbmV0ZGV2X2FsbG9jX2ZyYWcrMHgxY2Mv
MHgxZTgpClsgICA5NC42NjI1MTFdIFs8YzA0M2U5Zjg+XSAoX19uZXRkZXZfYWxsb2NfZnJhZysw
eDAvMHgxZTgpIGZyb20gWzxjMDQ0MTI4Yz5dIChfX25ldGRldl9hbGxvY19za2IrMHg4NC8weGUw
KQpbICAgOTQuNjcyNTA2XSBbPGMwNDQxMjA4Pl0gKF9fbmV0ZGV2X2FsbG9jX3NrYisweDAvMHhl
MCkgZnJvbSBbPGJmYzAxMzRjPl0gKF9ydHdfc2tiX2FsbG9jKzB4M2MvMHg0MCBbODgxMmF1XSkK
WyAgIDk0LjY4MjI5OV0gIHI2OjAwMDAwMDQ2IHI1OmQ0YWYyYWU4IHI0OjAwMDAwMDgyIHIzOjAw
MDAwMTAwClsgICA5NC42ODg2MzFdIFs8YmZjMDEzMTA+XSAoX3J0d19za2JfYWxsb2MrMHgwLzB4
NDAgWzg4MTJhdV0pIGZyb20gWzxiZmMxNGM4MD5dIChydHdfb3NfYWxsb2NfcmVjdmZyYW1lKzB4
NmMvMHhmYyBbODgxMmF1XSkKWyAgIDk0LjcwMDEyMV0gWzxiZmMxNGMxND5dIChydHdfb3NfYWxs
b2NfcmVjdmZyYW1lKzB4MC8weGZjIFs4ODEyYXVdKSBmcm9tIFs8YmZjNTdhMmM+XSAocmVjdmJ1
ZjJyZWN2ZnJhbWUrMHgyMzQvMHgzODggWzg4MTJhdV0pClsgICA5NC43MTIwNTBdIFs8YmZjNTc3
Zjg+XSAocmVjdmJ1ZjJyZWN2ZnJhbWUrMHgwLzB4Mzg4IFs4ODEyYXVdKSBmcm9tIFs8YmZjMDg0
Mzg+XSAodXNiX3JlY3ZfdGFza2xldCsweDZjLzB4OTQgWzg4MTJhdV0pClsgICA5NC43MjMwOTJd
IFs8YmZjMDgzY2M+XSAodXNiX3JlY3ZfdGFza2xldCsweDAvMHg5NCBbODgxMmF1XSkgZnJvbSBb
PGMwMDJkZTI0Pl0gKHRhc2tsZXRfYWN0aW9uKzB4YTgvMHgxNzgpClsgICA5NC43MzI3OTNdICBy
NzpjMDdiMjVlYyByNjowMDAwMDAwMCByNTpkNDgwOWI1YyByNDpkNDgwOWI1OApbICAgOTQuNzM4
NTAxXSBbPGMwMDJkZDdjPl0gKHRhc2tsZXRfYWN0aW9uKzB4MC8weDE3OCkgZnJvbSBbPGMwMDJj
ZGQwPl0gKF9fZG9fc29mdGlycSsweDE2NC8weDM0NCkKWyAgIDk0Ljc0NzI0NV0gIHI4OjAwMDAw
MDAwIHI3OjAwMDAwMDE4IHI2OmMwN2I4MDk4IHI1OmNmY2I2MDAwIHI0OjAwMDAwMDA2CnIzOmMw
MDJkZDdjClsgICA5NC43NTUxNDhdIFs8YzAwMmNjNmM+XSAoX19kb19zb2Z0aXJxKzB4MC8weDM0
NCkgZnJvbSBbPGMwMDJkMDE4Pl0gKHJ1bl9rc29mdGlycWQrMHg2OC8weGRjKQpbICAgOTQuNzYz
NjQ0XSBbPGMwMDJjZmIwPl0gKHJ1bl9rc29mdGlycWQrMHgwLzB4ZGMpIGZyb20gWzxjMDA1MmMz
ND5dIChzbXBib290X3RocmVhZF9mbisweDExMC8weDI0MCkKWyAgIDk0Ljc3MjY0OF0gIHI1OmNm
YzUxNzAwIHI0OmNmY2I2MDAwClsgICA5NC43NzYyNTJdIFs8YzAwNTJiMjQ+XSAoc21wYm9vdF90
aHJlYWRfZm4rMHgwLzB4MjQwKSBmcm9tIFs8YzAwNGExMDg+XSAoa3RocmVhZCsweGM0LzB4Yzgp
ClsgICA5NC43ODQ2NTZdICByODowMDAwMDAwMCByNzpjMDA1MmIyNCByNjpjZmM1MTcwMCByNTow
MDAwMDAwMCByNDpjZmNhZGU0NApyMzpjZmNhODU0MApbICAgOTQuNzkyNTY1XSBbPGMwMDRhMDQ0
Pl0gKGt0aHJlYWQrMHgwLzB4YzgpIGZyb20gWzxjMDAwZTQ0OD5dIChyZXRfZnJvbV9mb3JrKzB4
MTQvMHgyMCkKWyAgIDk0LjgwMDUzN10gIHI3OjAwMDAwMDAwIHI2OjAwMDAwMDAwIHI1OmMwMDRh
MDQ0IHI0OmNmY2FkZTQ0ClsgICA5NC44MDYyMzldIE1lbS1pbmZvOgpbICAgOTQuODA4NTAzXSBO
b3JtYWwgcGVyLWNwdToKWyAgIDk0LjgxMTI4N10gQ1BVICAgIDA6IGhpOiAgIDkwLCBidGNoOiAg
MTUgdXNkOiAgIDAKWyAgIDk0LjgxNjA1Nl0gQ1BVICAgIDE6IGhpOiAgIDkwLCBidGNoOiAgMTUg
dXNkOiAgMTQKWyAgIDk0LjgyMDgyNF0gSGlnaE1lbSBwZXItY3B1OgpbICAgOTQuODIzNjkzXSBD
UFUgICAgMDogaGk6ICAgMTgsIGJ0Y2g6ICAgMyB1c2Q6ICAgMApbICAgOTQuODI4NDYzXSBDUFUg
ICAgMTogaGk6ICAgMTgsIGJ0Y2g6ICAgMyB1c2Q6ICAgMApbICAgOTQuODMzMjQwXSBhY3RpdmVf
YW5vbjozODM1OSBpbmFjdGl2ZV9hbm9uOjEzOCBpc29sYXRlZF9hbm9uOjAKWyAgIDk0LjgzMzI0
MF0gIGFjdGl2ZV9maWxlOjQ0MDcgaW5hY3RpdmVfZmlsZToxNTc0NyBpc29sYXRlZF9maWxlOjI5
NgpbICAgOTQuODMzMjQwXSAgdW5ldmljdGFibGU6MCBkaXJ0eTo4NjQ0IHdyaXRlYmFjazo4MTQg
dW5zdGFibGU6MApbICAgOTQuODMzMjQwXSAgZnJlZToyNDA2NCBzbGFiX3JlY2xhaW1hYmxlOjM4
Nzggc2xhYl91bnJlY2xhaW1hYmxlOjUzNTYKWyAgIDk0LjgzMzI0MF0gIG1hcHBlZDo2OTg4IHNo
bWVtOjE0NSBwYWdldGFibGVzOjU5MyBib3VuY2U6MApbICAgOTQuODMzMjQwXSAgZnJlZV9jbWE6
MTU3NzAKWyAgIDk0Ljg2NTc3Nl0gTm9ybWFsIGZyZWU6NjM3NjhrQiBtaW46MjAwMGtCIGxvdzoy
NTAwa0IgaGlnaDozMDAwa0IgYWN0aXZlX2Fub246MTI4NjAwa0IgaW5hY3RpdmVfYW5vbjozMDRr
QiBhY3RpdmVfZmlsZToxNDA0NGtCIGluYWN0aXZlX2ZpbGU6MzY3MDhrQiB1bmV2aWN0YWJsZTow
a0IgaXNvbGF0ZWQoYW5vbik6MGtCIGlzb2xhdGVkKGZpbGUpOjExODRrQiBwcmVzZW50OjMyOTcy
OGtCIG1hbmFnZWQ6MjUwNDA4a0IgbWxvY2tlZDowa0IgZGlydHk6MzQ1NzZrQiB3cml0ZWJhY2s6
MzI1NmtCIG1hcHBlZDoxMjI2MGtCIHNobWVtOjMwOGtCIHNsYWJfcmVjbGFpbWFibGU6MTU1MTJr
QiBzbGFiX3VucmVjbGFpbWFibGU6MjE0MjRrQiBrZXJuZWxfc3RhY2s6MjM5MmtCIHBhZ2V0YWJs
ZXM6MjM3MmtCIHVuc3RhYmxlOjBrQiBib3VuY2U6MGtCIGZyZWVfY21hOjYzMDgwa0Igd3JpdGVi
YWNrX3RtcDowa0IgcGFnZXNfc2Nhbm5lZDo1OTkgYWxsX3VucmVjbGFpbWFibGU/IG5vClsgICA5
NC45MDkyNzBdIGxvd21lbV9yZXNlcnZlW106IDAgNjk2IDY5NgpbICAgOTQuOTEzMTcyXSBIaWdo
TWVtIGZyZWU6MzI0NjBrQiBtaW46MTI4a0IgbG93OjMwNGtCIGhpZ2g6NDgwa0IgYWN0aXZlX2Fu
b246MjQ4MzZrQiBpbmFjdGl2ZV9hbm9uOjI0OGtCIGFjdGl2ZV9maWxlOjM1ODRrQiBpbmFjdGl2
ZV9maWxlOjI2MzE2a0IgdW5ldmljdGFibGU6MGtCIGlzb2xhdGVkKGFub24pOjBrQiBpc29sYXRl
ZChmaWxlKTowa0IgcHJlc2VudDo4OTA4OGtCIG1hbmFnZWQ6ODkwODhrQiBtbG9ja2VkOjBrQiBk
aXJ0eTowa0Igd3JpdGViYWNrOjBrQiBtYXBwZWQ6MTU2OTJrQiBzaG1lbToyNzJrQiBzbGFiX3Jl
Y2xhaW1hYmxlOjBrQiBzbGFiX3VucmVjbGFpbWFibGU6MGtCIGtlcm5lbF9zdGFjazowa0IgcGFn
ZXRhYmxlczowa0IgdW5zdGFibGU6MGtCIGJvdW5jZTowa0IgZnJlZV9jbWE6MGtCIHdyaXRlYmFj
a190bXA6MGtCIHBhZ2VzX3NjYW5uZWQ6MCBhbGxfdW5yZWNsYWltYWJsZT8gbm8KWyAgIDk0Ljk1
MzU1MF0gbG93bWVtX3Jlc2VydmVbXTogMCAwIDAKWyAgIDk0Ljk1NzA5M10gTm9ybWFsOiAzOTAq
NGtCIChNQykgMjI2KjhrQiAoQykgMjI1KjE2a0IgKEMpIDIyNiozMmtCIChDKSAyMjYqNjRrQiAo
QykgMjI2KjEyOGtCIChDKSAxNCoyNTZrQiAoQykgNSo1MTJrQiAoQykgMCoxMDI0a0IgMCoyMDQ4
a0IgMCo0MDk2a0IgPSA2MzczNmtCClsgICA5NC45NzE2MjZdIEhpZ2hNZW06IDEwNTUqNGtCIChN
UikgNTUzKjhrQiAoVU1SKSAyMzEqMTZrQiAoVU1SKSAxMjMqMzJrQiAoVU1SKSA5MSo2NGtCIChV
TVIpIDc5KjEyOGtCIChVTVIpIDEqMjU2a0IgKFIpIDAqNTEya0IgMCoxMDI0a0IgMCoyMDQ4a0Ig
MCo0MDk2a0IgPSAzMjQ2OGtCClsgICA5NC45ODY1NzRdIDIwNTg4IHRvdGFsIHBhZ2VjYWNoZSBw
YWdlcwpbICAgOTQuOTkwMzk3XSAwIHBhZ2VzIGluIHN3YXAgY2FjaGUKWyAgIDk0Ljk5MzcwMl0g
U3dhcCBjYWNoZSBzdGF0czogYWRkIDAsIGRlbGV0ZSAwLCBmaW5kIDAvMApbICAgOTQuOTk4OTAy
XSBGcmVlIHN3YXAgID0gMGtCClsgICA5NS4wMDE3NzBdIFRvdGFsIHN3YXAgPSAwa0IKWyAgIDk1
LjAwNTM5N10gUlRMODcxWDogcnR3X29zX2FsbG9jX3JlY3ZmcmFtZTpjYW4gbm90IGFsbG9jYXRl
IG1lbW9yeSBmb3Igc2tiIGNvcHkKCg==
--001a11419becc9fc3b05337cd10b
Content-Type: text/plain; charset=US-ASCII; name="page_alloc_fail_pcp_NOT_0.txt"
Content-Disposition: attachment; filename="page_alloc_fail_pcp_NOT_0.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iojnh2tp1

WyA4NjA2LjcwMTM0M10gQ29tcG9zaXRvclRpbGVXOiBwYWdlIGFsbG9jYXRpb24gZmFpbHVyZTog
b3JkZXI6MCwgbW9kZToweDIwClsgODYwNi43MDEzNTZdIENQVTogMCBQSUQ6IDI2MDY0IENvbW06
IENvbXBvc2l0b3JUaWxlVyBUYWludGVkOiBHICAgICAgICAgICBPIDMuMTAuMCsgIzIKWyA4NjA2
LjcwMTM2NV0gQmFja3RyYWNlOiAKWyA4NjA2LjcwMTM5MF0gWzxjMDAxMjlmOD5dIChkdW1wX2Jh
Y2t0cmFjZSsweDAvMHgxMTQpIGZyb20gWzxjMDAxMmM2OD5dIChzaG93X3N0YWNrKzB4MjAvMHgy
NCkKWyA4NjA2LjcwMTQwM10gIHI2OmM5YmVlMDAwIHI1OjAwMDAwMDAwIHI0OjAwMDAwMDIwIHIz
OjI3MWFlNzFjClsgODYwNi43MDE0MTldIFs8YzAwMTJjNDg+XSAoc2hvd19zdGFjaysweDAvMHgy
NCkgZnJvbSBbPGMwNTZkMmVjPl0gKGR1bXBfc3RhY2srMHgyNC8weDI4KQpbIDg2MDYuNzAxNDM0
XSBbPGMwNTZkMmM4Pl0gKGR1bXBfc3RhY2srMHgwLzB4MjgpIGZyb20gWzxjMDEwYzY2OD5dICh3
YXJuX2FsbG9jX2ZhaWxlZCsweGVjLzB4MTI4KQpbIDg2MDYuNzAxNDQ3XSBbPGMwMTBjNTdjPl0g
KHdhcm5fYWxsb2NfZmFpbGVkKzB4MC8weDEyOCkgZnJvbSBbPGMwMTBmZDFjPl0gKF9fYWxsb2Nf
cGFnZXNfbm9kZW1hc2srMHg3MGMvMHg5NDApClsgODYwNi43MDE0NTZdICByMzowMDAwMDAwMCBy
MjowMDAwMDAwMApbIDg2MDYuNzAxNDY2XSAgcjc6YzA3ZmUyNDAgcjY6MDAwMDAwMDAgcjU6MDAw
MDAwMDAgcjQ6MDAwMDAwMjAKWyA4NjA2LjcwMTQ3Nl0gWzxjMDEwZjYxMD5dIChfX2FsbG9jX3Bh
Z2VzX25vZGVtYXNrKzB4MC8weDk0MCkgZnJvbSBbPGMwNDNlYmM0Pl0gKF9fbmV0ZGV2X2FsbG9j
X2ZyYWcrMHgxY2MvMHgxZTgpClsgODYwNi43MDE0ODddIFs8YzA0M2U5Zjg+XSAoX19uZXRkZXZf
YWxsb2NfZnJhZysweDAvMHgxZTgpIGZyb20gWzxjMDQ0MTI4Yz5dIChfX25ldGRldl9hbGxvY19z
a2IrMHg4NC8weGUwKQpbIDg2MDYuNzAxOTQzXSBbPGMwNDQxMjA4Pl0gKF9fbmV0ZGV2X2FsbG9j
X3NrYisweDAvMHhlMCkgZnJvbSBbPGJmYmY4MzRjPl0gKF9ydHdfc2tiX2FsbG9jKzB4M2MvMHg0
MCBbODgxMmF1XSkKWyA4NjA2LjcwMTk1OF0gIHI2OjAwMDAwNjBlIHI1OmQ0YWYzMTYwIHI0OjAw
MDAwNjRhIHIzOjAwMDAwMTAwClsgODYwNi43MDIzNzRdIFs8YmZiZjgzMTA+XSAoX3J0d19za2Jf
YWxsb2MrMHgwLzB4NDAgWzg4MTJhdV0pIGZyb20gWzxiZmMwYmM4MD5dIChydHdfb3NfYWxsb2Nf
cmVjdmZyYW1lKzB4NmMvMHhmYyBbODgxMmF1XSkKWyA4NjA2LjcwMjc5NV0gWzxiZmMwYmMxND5d
IChydHdfb3NfYWxsb2NfcmVjdmZyYW1lKzB4MC8weGZjIFs4ODEyYXVdKSBmcm9tIFs8YmZjNGVi
NjQ+XSAocmVjdmJ1ZjJyZWN2ZnJhbWUrMHgzNmMvMHgzODggWzg4MTJhdV0pClsgODYwNi43MDMx
OTNdIFs8YmZjNGU3Zjg+XSAocmVjdmJ1ZjJyZWN2ZnJhbWUrMHgwLzB4Mzg4IFs4ODEyYXVdKSBm
cm9tIFs8YmZiZmY0Mzg+XSAodXNiX3JlY3ZfdGFza2xldCsweDZjLzB4OTQgWzg4MTJhdV0pClsg
ODYwNi43MDMzODVdIFs8YmZiZmYzY2M+XSAodXNiX3JlY3ZfdGFza2xldCsweDAvMHg5NCBbODgx
MmF1XSkgZnJvbSBbPGMwMDJkZTI0Pl0gKHRhc2tsZXRfYWN0aW9uKzB4YTgvMHgxNzgpClsgODYw
Ni43MDMzOThdICByNzpjMDdiMjVlYyByNjowMDAwMDAwMCByNTpkNDgwOWI1YyByNDpkNDgwOWI1
OApbIDg2MDYuNzAzNDA3XSBbPGMwMDJkZDdjPl0gKHRhc2tsZXRfYWN0aW9uKzB4MC8weDE3OCkg
ZnJvbSBbPGMwMDJjZGQwPl0gKF9fZG9fc29mdGlycSsweDE2NC8weDM0NCkKWyA4NjA2LjcwMzQy
M10gIHI4OjAwMDAwMDA4IHI3OjAwMDAwMDE4IHI2OmMwN2I4MDk4IHI1OmM5YmVlMDAwIHI0OjAw
MDAwMDA2ClsgODYwNi43MDM0MjNdIHIzOmMwMDJkZDdjClsgODYwNi43MDM0MzFdIFs8YzAwMmNj
NmM+XSAoX19kb19zb2Z0aXJxKzB4MC8weDM0NCkgZnJvbSBbPGMwMDJkNTMwPl0gKGlycV9leGl0
KzB4YmMvMHhmMCkKWyA4NjA2LjcwMzQ0NF0gWzxjMDAyZDQ3ND5dIChpcnFfZXhpdCsweDAvMHhm
MCkgZnJvbSBbPGMwMDBlZGEwPl0gKGhhbmRsZV9JUlErMHg1NC8weGEwKQpbIDg2MDYuNzAzNDUy
XSAgcjU6MDAwMDAwNTYgcjQ6YzA3YjNmNDAKWyA4NjA2LjcwMzQ2MF0gWzxjMDAwZWQ0Yz5dICho
YW5kbGVfSVJRKzB4MC8weGEwKSBmcm9tIFs8YzAwMDg1OTQ+XSAoZ2ljX2hhbmRsZV9pcnErMHgz
Yy8weDZjKQpbIDg2MDYuNzAzNDcyXSAgcjY6YzliZWZmYjAgcjU6YzA3YzgyY2MgcjQ6ZmVmZmUx
MGMgcjM6MDAwMDAwMDAKWyA4NjA2LjcwMzQ4M10gWzxjMDAwODU1OD5dIChnaWNfaGFuZGxlX2ly
cSsweDAvMHg2YykgZnJvbSBbPGMwNTcxOGU0Pl0gKF9faXJxX3VzcisweDQ0LzB4NjApClsgODYw
Ni43MDM0ODldIEV4Y2VwdGlvbiBzdGFjaygweGM5YmVmZmIwIHRvIDB4YzliZWZmZjgpClsgODYw
Ni43MDM0OTVdIGZmYTA6ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAw
MDAxIDAxNTgxNjAwIDIwZThmY2Y2IDAwMDAwMDAxClsgODYwNi43MDM1MDRdIGZmYzA6IDAwMDAw
MDEzIDRmYjE0OWEwIDAwMDAwMDA3IGZmZmZmZmZmIDAwMDAwMDA4IDAwMDAwMDAxIDAwMDAwMDA5
IDAxNTgwYmM0ClsgODYwNi43MDM1MTJdIGZmZTA6IDAwMDAwMDBjIGIwMTVhZmEwIGI1ZGUwY2I4
IGIzNmI3NGM4IDAwMDcwMTcwIGZmZmZmZmZmIGZmMTIxMjEyClsgODYwNi43MDM1MjRdICByNzpm
ZmZmZmZmZiByNjpmZmZmZmZmZiByNTowMDA3MDE3MCByNDpiMzZiNzRjOApbIDg2MDYuNzAzNTI2
XSBNZW0taW5mbzoKWyA4NjA2LjcwMzUzMF0gTm9ybWFsIHBlci1jcHU6ClsgODYwNi43MDM1MzVd
IENQVSAgICAwOiBoaTogICA5MCwgYnRjaDogIDE1IHVzZDogIDEwClsgODYwNi43MDM1NDBdIENQ
VSAgICAxOiBoaTogICA5MCwgYnRjaDogIDE1IHVzZDogIDQ3ClsgODYwNi43MDM1NDNdIEhpZ2hN
ZW0gcGVyLWNwdToKWyA4NjA2LjcwMzU0N10gQ1BVICAgIDA6IGhpOiAgIDE4LCBidGNoOiAgIDMg
dXNkOiAgIDIKWyA4NjA2LjcwMzU1MV0gQ1BVICAgIDE6IGhpOiAgIDE4LCBidGNoOiAgIDMgdXNk
OiAgIDIKWyA4NjA2LjcwMzU2NF0gYWN0aXZlX2Fub246MzE2NDkgaW5hY3RpdmVfYW5vbjo2MjMy
IGlzb2xhdGVkX2Fub246MApbIDg2MDYuNzAzNTY0XSAgYWN0aXZlX2ZpbGU6NDMwMyBpbmFjdGl2
ZV9maWxlOjE3Mjk5IGlzb2xhdGVkX2ZpbGU6MApbIDg2MDYuNzAzNTY0XSAgdW5ldmljdGFibGU6
MCBkaXJ0eToxNDYgd3JpdGViYWNrOjAgdW5zdGFibGU6MApbIDg2MDYuNzAzNTY0XSAgZnJlZTox
NTI0NiBzbGFiX3JlY2xhaW1hYmxlOjE0Njkgc2xhYl91bnJlY2xhaW1hYmxlOjY2MjkKWyA4NjA2
LjcwMzU2NF0gIG1hcHBlZDoxNzM4MCBzaG1lbTo2MjY2IHBhZ2V0YWJsZXM6ODg0IGJvdW5jZTow
ClsgODYwNi43MDM1NjRdICBmcmVlX2NtYToxNDk5MQpbIDg2MDYuNzAzNTkwXSBOb3JtYWwgZnJl
ZTo2MDY4NGtCIG1pbjoyMDAwa0IgbG93OjI1MDBrQiBoaWdoOjMwMDBrQiBhY3RpdmVfYW5vbjo4
NDE4OGtCIGluYWN0aXZlX2Fub246MjQwMzJrQiBhY3RpdmVfZmlsZTo3NjMya0IgaW5hY3RpdmVf
ZmlsZTozNDgxMmtCIHVuZXZpY3RhYmxlOjBrQiBpc29sYXRlZChhbm9uKTowa0IgaXNvbGF0ZWQo
ZmlsZSk6MGtCIHByZXNlbnQ6MzI5NzI4a0IgbWFuYWdlZDoyNTA0MDhrQiBtbG9ja2VkOjBrQiBk
aXJ0eTo1NjhrQiB3cml0ZWJhY2s6MGtCIG1hcHBlZDo0MzEyNGtCIHNobWVtOjI0MTQ4a0Igc2xh
Yl9yZWNsYWltYWJsZTo1ODc2a0Igc2xhYl91bnJlY2xhaW1hYmxlOjI2NTE2a0Iga2VybmVsX3N0
YWNrOjI2NTZrQiBwYWdldGFibGVzOjM1MzZrQiB1bnN0YWJsZTowa0IgYm91bmNlOjBrQiBmcmVl
X2NtYTo1OTk2NGtCIHdyaXRlYmFja190bXA6MGtCIHBhZ2VzX3NjYW5uZWQ6NjggYWxsX3VucmVj
bGFpbWFibGU/IG5vClsgODYwNi43MDM2MTBdIGxvd21lbV9yZXNlcnZlW106IDAgNjk2IDY5Ngpb
IDg2MDYuNzAzNjI1XSBIaWdoTWVtIGZyZWU6MzAwa0IgbWluOjEyOGtCIGxvdzozMDRrQiBoaWdo
OjQ4MGtCIGFjdGl2ZV9hbm9uOjQyNDA4a0IgaW5hY3RpdmVfYW5vbjo4OTZrQiBhY3RpdmVfZmls
ZTo5NTgwa0IgaW5hY3RpdmVfZmlsZTozNDM4NGtCIHVuZXZpY3RhYmxlOjBrQiBpc29sYXRlZChh
bm9uKTowa0IgaXNvbGF0ZWQoZmlsZSk6MGtCIHByZXNlbnQ6ODkwODhrQiBtYW5hZ2VkOjg5MDg4
a0IgbWxvY2tlZDowa0IgZGlydHk6MTZrQiB3cml0ZWJhY2s6MGtCIG1hcHBlZDoyNjM5NmtCIHNo
bWVtOjkxNmtCIHNsYWJfcmVjbGFpbWFibGU6MGtCIHNsYWJfdW5yZWNsYWltYWJsZTowa0Iga2Vy
bmVsX3N0YWNrOjBrQiBwYWdldGFibGVzOjBrQiB1bnN0YWJsZTowa0IgYm91bmNlOjBrQiBmcmVl
X2NtYTowa0Igd3JpdGViYWNrX3RtcDowa0IgcGFnZXNfc2Nhbm5lZDowIGFsbF91bnJlY2xhaW1h
YmxlPyBubwpbIDg2MDYuNzAzNjQ0XSBsb3dtZW1fcmVzZXJ2ZVtdOiAwIDAgMApbIDg2MDYuNzAz
Njc2XSBOb3JtYWw6IDEwMTMqNGtCIChVQykgMTAxMyo4a0IgKFVNQykgMTAxMyoxNmtCIChVQykg
MTAwMiozMmtCIChVQykgNCo2NGtCIChVKSAwKjEyOGtCIDAqMjU2a0IgMCo1MTJrQiAwKjEwMjRr
QiAwKjIwNDhrQiAwKjQwOTZrQiA9IDYwNjg0a0IKWyA4NjA2LjcwMzcwNl0gSGlnaE1lbTogMyo0
a0IgKE0pIDIqOGtCIChSKSAxKjE2a0IgKFIpIDAqMzJrQiAwKjY0a0IgMCoxMjhrQiAxKjI1NmtC
IChSKSAwKjUxMmtCIDAqMTAyNGtCIDAqMjA0OGtCIDAqNDA5NmtCID0gMzAwa0IKWyA4NjA2Ljcw
MzcwOF0gMjc4NzYgdG90YWwgcGFnZWNhY2hlIHBhZ2VzClsgODYwNi43MDM3MTVdIDAgcGFnZXMg
aW4gc3dhcCBjYWNoZQpbIDg2MDYuNzAzNzE5XSBTd2FwIGNhY2hlIHN0YXRzOiBhZGQgMCwgZGVs
ZXRlIDAsIGZpbmQgMC8wClsgODYwNi43MDM3MjJdIEZyZWUgc3dhcCAgPSAwa0IKWyA4NjA2Ljcw
MzcyNF0gVG90YWwgc3dhcCA9IDBrQgpbIDg2MDYuNzAzODQwXSBSVEw4NzFYOiBydHdfb3NfYWxs
b2NfcmVjdmZyYW1lOmNhbiBub3QgYWxsb2NhdGUgbWVtb3J5IGZvciBza2IgY29weQoK
--001a11419becc9fc3b05337cd10b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
