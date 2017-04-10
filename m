Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C50026B0038
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:10:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a72so122554099pge.10
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:10:35 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id b10si13456815plk.334.2017.04.10.05.10.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 05:10:33 -0700 (PDT)
Message-ID: <58EB761E.9040002@huawei.com>
Date: Mon, 10 Apr 2017 20:10:06 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: NULL pointer dereference in the kernel 3.10
References: <58E8E81E.6090304@huawei.com> <20170410085604.zpenj6ggc3dsbgxw@techsingularity.net>
In-Reply-To: <20170410085604.zpenj6ggc3dsbgxw@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, Vlastimil Babka <vbabka@suse.cz>, Linux Memory
 Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2017/4/10 16:56, Mel Gorman wrote:
> On Sat, Apr 08, 2017 at 09:39:42PM +0800, zhong jiang wrote:
>> when runing the stabile docker cases in the vm.   The following issue will come up.
>>
>> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
>>     [exception RIP: down_read_trylock+5]
>>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
>>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
>>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
>>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
>>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
>>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
>>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
> Post the full report including the kernel version and state whether any
> additional patches to 3.10 are applied.
>
 Hi, Mel
   
        Our kernel from RHEL 7.2, Addtional patches all from upstream -- include Bugfix and CVE.

Commit 624483f3ea8 ("mm: rmap: fix use-after-free in __put_anon_vma") exclude in
the RHEL 7.2. it looks seems to the issue. but I don't know how it triggered.
or it is not the correct fix.  Any suggestion? Thanks


partly dmesg will print in the following.

[59982.162223] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[59985.261635] device-mapper: ioctl: remove_all left 8 open device(s)
[59986.492174] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[59987.445606] device-mapper: ioctl: remove_all left 8 open device(s)
[59987.625887] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[59988.174600] device-mapper: ioctl: remove_all left 8 open device(s)
[59988.345667] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[59990.951713] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[59991.025185] device vethd295793 entered promiscuous mode
[59991.025253] IPv6: ADDRCONF(NETDEV_UP): vethd295793: link is not ready
[59991.860817] IPv6: ADDRCONF(NETDEV_CHANGE): vethd295793: link becomes ready
[59991.860836] docker0: port 4(vethd295793) entered forwarding state
[59991.860840] docker0: port 4(vethd295793) entered forwarding state
[59992.704027] docker0: port 4(vethd295793) entered disabled state
[59992.724049] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[59993.098341] docker0: port 4(vethd295793) entered disabled state
[59993.102583] device vethd295793 left promiscuous mode
[59993.102605] docker0: port 4(vethd295793) entered disabled state
[59995.109048] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[59995.229390] docker0: port 2(veth2ad76e2) entered disabled state
[59995.523997] docker0: port 2(veth2ad76e2) entered disabled state
[59995.528183] device veth2ad76e2 left promiscuous mode
[59995.528202] docker0: port 2(veth2ad76e2) entered disabled state
[59995.975559] device-mapper: ioctl: remove_all left 8 open device(s)
[59996.084575] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[59996.660641] device-mapper: ioctl: remove_all left 7 open device(s)
[59997.109018] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[59998.360101] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60001.721429] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60001.771433] device vethcca3b6a entered promiscuous mode
[60001.771643] IPv6: ADDRCONF(NETDEV_UP): vethcca3b6a: link is not ready
[60002.872102] IPv6: ADDRCONF(NETDEV_CHANGE): vethcca3b6a: link becomes ready
[60002.872124] docker0: port 2(vethcca3b6a) entered forwarding state
[60002.872130] docker0: port 2(vethcca3b6a) entered forwarding state
[60005.041654] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60005.597179] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60013.731728] [/usr/bin/os_rotate_and_save_log.sh]space of output directory is larger than 500M bytes,delete the oldest tar file messages-20170321181104-129.tar.bz2
[60016.243601] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60016.669594] device-mapper: ioctl: remove_all left 9 open device(s)
[60016.930232] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[60017.918511] docker0: port 2(vethcca3b6a) entered forwarding state
[60022.197574] device-mapper: ioctl: remove_all left 8 open device(s)
[60022.575774] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60023.288744] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60024.282579] device-mapper: ioctl: remove_all left 8 open device(s)
[60024.505905] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60024.934311] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60025.168626] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60025.213931] device vethacdb1d3 entered promiscuous mode
[60025.214023] IPv6: ADDRCONF(NETDEV_UP): vethacdb1d3: link is not ready
[60026.095253] IPv6: ADDRCONF(NETDEV_CHANGE): vethacdb1d3: link becomes ready
[60026.095286] docker0: port 4(vethacdb1d3) entered forwarding state
[60026.095293] docker0: port 4(vethacdb1d3) entered forwarding state
[60027.000131] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60027.275219] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60027.720511] docker0: port 4(vethacdb1d3) entered disabled state
[60027.904669] docker0: port 4(vethacdb1d3) entered disabled state
[60027.908548] device vethacdb1d3 left promiscuous mode
[60027.908570] docker0: port 4(vethacdb1d3) entered disabled state
[60028.355696] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60028.422053] device veth5f1b1ca entered promiscuous mode
[60028.422235] IPv6: ADDRCONF(NETDEV_UP): veth5f1b1ca: link is not ready
[60029.189057] IPv6: ADDRCONF(NETDEV_CHANGE): veth5f1b1ca: link becomes ready
[60029.189106] docker0: port 4(veth5f1b1ca) entered forwarding state
[60029.189113] docker0: port 4(veth5f1b1ca) entered forwarding state
[60030.497583] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60030.513251] docker0: port 4(veth5f1b1ca) entered disabled state
[60032.548765] docker0: port 4(veth5f1b1ca) entered disabled state
[60032.552584] device veth5f1b1ca left promiscuous mode
[60032.552608] docker0: port 4(veth5f1b1ca) entered disabled state
[60033.323499] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60033.743783] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60034.124363] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60034.745977] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60035.290592] device-mapper: ioctl: remove_all left 9 open device(s)
[60035.631079] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[60036.143921] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[60036.523837] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60036.917809] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60046.916546] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60060.427591] device-mapper: ioctl: remove_all left 7 open device(s)
[60061.378699] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60062.187386] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60062.685578] device-mapper: ioctl: remove_all left 8 open device(s)
[60062.918018] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60063.182233] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60063.925052] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60064.354388] docker0: port 2(vethcca3b6a) entered disabled state
[60064.514541] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60064.580908] docker0: port 2(vethcca3b6a) entered disabled state
[60064.584794] device vethcca3b6a left promiscuous mode
[60064.584807] docker0: port 2(vethcca3b6a) entered disabled state
[60065.190575] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[60065.267425] device veth5ae4b28 entered promiscuous mode
[60065.267839] IPv6: ADDRCONF(NETDEV_UP): veth5ae4b28: link is not ready
[60066.838868] IPv6: ADDRCONF(NETDEV_CHANGE): veth5ae4b28: link becomes ready
[60066.838893] docker0: port 2(veth5ae4b28) entered forwarding state
[60066.838899] docker0: port 2(veth5ae4b28) entered forwarding state
[60067.701573] docker0: port 2(veth5ae4b28) entered disabled state
[60068.117747] docker0: port 2(veth5ae4b28) entered disabled state
[60068.124996] device veth5ae4b28 left promiscuous mode
[60068.125020] docker0: port 2(veth5ae4b28) entered disabled state
[60069.120881] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60069.620570] device-mapper: ioctl: remove_all left 7 open device(s)
[60069.721708] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60070.196476] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[60070.216278] device veth1709f7b entered promiscuous mode
[60070.216350] IPv6: ADDRCONF(NETDEV_UP): veth1709f7b: link is not ready
[60070.692079] IPv6: ADDRCONF(NETDEV_CHANGE): veth1709f7b: link becomes ready
[60070.692099] docker0: port 2(veth1709f7b) entered forwarding state
[60070.692104] docker0: port 2(veth1709f7b) entered forwarding state
[60070.698211] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60070.884584] device-mapper: ioctl: remove_all left 7 open device(s)
[60072.819916] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60073.833590] device-mapper: ioctl: remove_all left 7 open device(s)
[60074.082847] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60082.504842] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60083.298148] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60083.679313] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60084.745280] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60085.694519] docker0: port 2(veth1709f7b) entered forwarding state
[60086.052328] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60086.618181] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[60087.131614] device-mapper: ioctl: remove_all left 9 open device(s)
[60087.419709] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60088.086751] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60091.954031] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60092.217529] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[60092.775974] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[60095.231733] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[60095.256537] device veth60b0427 entered promiscuous mode
[60095.256619] IPv6: ADDRCONF(NETDEV_UP): veth60b0427: link is not ready
[60095.256624] docker0: port 4(veth60b0427) entered forwarding state
uitcrash> dmesg
[58913.919584] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58925.853603] device-mapper: ioctl: remove_all left 8 open device(s)
[58926.066492] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58929.208621] device-mapper: ioctl: remove_all left 7 open device(s)
[58929.737954] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[58930.619791] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58931.602116] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58932.036570] device-mapper: ioctl: remove_all left 9 open device(s)
[58932.301732] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[58933.220390] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58933.595871] docker0: port 4(veth0280f18) entered disabled state
[58933.757559] docker0: port 4(veth0280f18) entered disabled state
[58933.761922] device veth0280f18 left promiscuous mode
[58933.761940] docker0: port 4(veth0280f18) entered disabled state
[58934.219205] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[58934.241650] device veth64ac507 entered promiscuous mode
[58934.241849] IPv6: ADDRCONF(NETDEV_UP): veth64ac507: link is not ready
[58935.327295] IPv6: ADDRCONF(NETDEV_CHANGE): veth64ac507: link becomes ready
[58935.327326] docker0: port 2(veth64ac507) entered forwarding state
[58935.327332] docker0: port 2(veth64ac507) entered forwarding state
[58935.557921] docker0: port 2(veth64ac507) entered disabled state
[58935.659668] docker0: port 2(veth64ac507) entered disabled state
[58935.663329] device veth64ac507 left promiscuous mode
[58935.663343] docker0: port 2(veth64ac507) entered disabled state
[58935.739020] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[58935.854853] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[58936.248296] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58936.544557] device-mapper: ioctl: remove_all left 7 open device(s)
[58936.640359] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: (null)
[58936.691418] device vethf82c96f entered promiscuous mode
[58936.691523] IPv6: ADDRCONF(NETDEV_UP): vethf82c96f: link is not ready
[58937.387892] IPv6: ADDRCONF(NETDEV_CHANGE): vethf82c96f: link becomes ready
[58937.387911] docker0: port 2(vethf82c96f) entered forwarding state
[58937.387915] docker0: port 2(vethf82c96f) entered forwarding state
[58937.633103] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[58938.113015] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58941.570360] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[58942.331612] device-mapper: ioctl: remove_all left 7 open device(s)
[58942.556858] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58943.097591] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58943.743816] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: (null)
[58944.263205] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58945.017670] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[58946.468176] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[58946.881381] [/usr/bin/os_rotate_and_save_log.sh]space of output directory is larger than 500M bytes,delete the oldest tar file messages-20170321173755-122.tar.bz2
[58948.679535] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58949.065572] device-mapper: ioctl: remove_all left 9 open device(s)
[58949.229711] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58949.979575] device-mapper: ioctl: remove_all left 8 open device(s)
[58950.373339] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58951.166548] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58951.486803] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58952.414514] docker0: port 2(vethf82c96f) entered forwarding state
[58952.495260] EXT4-fs (dm-6): mounted filesystem with ordered data mode. Opts: (null)
[58953.268687] EXT4-fs (dm-9): mounted filesystem with ordered data mode. Opts: (null)
[58953.973573] device-mapper: ioctl: remove_all left 10 open device(s)
[58954.336967] EXT4-fs (dm-10): mounted filesystem with ordered data mode. Opts: (null)
[58954.404284] device veth7697107 entered promiscuous mode
[58954.404389] IPv6: ADDRCONF(NETDEV_UP): veth7697107: link is not ready
[58955.361244] IPv6: ADDRCONF(NETDEV_CHANGE): veth7697107: link becomes ready
[58955.361274] docker0: port 4(veth7697107) entered forwarding state
[58955.361280] docker0: port 4(veth7697107) entered forwarding state
[58959.547644] docker0: port 4(veth7697107) entered disabled state
[58959.597633] EXT4-fs (dm-8): mounted filesystem with ordered data mode. Opts: (null)
[58959.822261] docker0: port 4(veth7697107) entered disabled state
...skipping...
[70244.508227] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[70244.510880] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[70244.513241] Stack:
[70244.515503]  0000000400040000 ffff880100000000 0000000000000000 ffff8800b17b9000
[70244.519526]  0000000000000008 0000000000000000 0000000000000000 0000000000000010
[70244.523612]  0000000000000000 0000000500000001 0000000000000040 0000020000000000
[70244.526997] Call Trace:
[70244.529851]  [<ffffffff81063866>] _set_pages_array+0xe6/0x130
[70244.532971]  [<ffffffff810638e3>] set_pages_array_wc+0x13/0x20
[70244.535419]  [<ffffffffa02892af>] ttm_set_pages_caching+0x2f/0x70 [ttm]
[70244.538553]  [<ffffffffa02893f4>] ttm_alloc_new_pages.isra.6+0xb4/0x180 [ttm]
[70244.542124]  [<ffffffffa0289d63>] ttm_pool_populate+0x3e3/0x500 [ttm]
[70244.545800]  [<ffffffffa02243ee>] cirrus_ttm_tt_populate+0xe/0x10 [cirrus]
[70244.548742]  [<ffffffffa02865a5>] ttm_bo_move_memcpy+0x655/0x6d0 [ttm]
[70244.552133]  [<ffffffffa0224398>] cirrus_bo_move+0x18/0x20 [cirrus]
[70244.554460]  [<ffffffffa0283cf5>] ttm_bo_handle_move_mem+0x265/0x5b0 [ttm]
[70244.557331]  [<ffffffffa0284657>] ? ttm_bo_mem_space+0xe7/0x350 [ttm]
[70244.559991]  [<ffffffffa0284d4d>] ttm_bo_validate+0x20d/0x230 [ttm]
[70244.563725]  [<ffffffffa0224b73>] cirrus_bo_push_sysram+0x93/0xe0 [cirrus]
[70244.567694]  [<ffffffffa0222d34>] cirrus_crtc_do_set_base.isra.9.constprop.11+0x84/0x410 [cirrus]
[70244.571073]  [<ffffffffa0223515>] cirrus_crtc_mode_set+0x455/0x4e0 [cirrus]
[70244.573303]  [<ffffffffa02a3969>] drm_crtc_helper_set_mode+0x319/0x550 [drm_kms_helper]
[70244.575818]  [<ffffffffa02a49d2>] drm_crtc_helper_set_config+0x892/0xab0 [drm_kms_helper]
[70244.578344]  [<ffffffffa023add7>] drm_mode_set_config_internal+0x67/0x100 [drm]
[70244.580874]  [<ffffffffa02b0100>] drm_fb_helper_pan_display+0xa0/0xf0 [drm_kms_helper]
[70244.583298]  [<ffffffff81361a39>] fb_pan_display+0xc9/0x190
[70244.585517]  [<ffffffff81370c50>] bit_update_start+0x20/0x50
[70244.587552]  [<ffffffff8136f43d>] fbcon_switch+0x39d/0x5a0
[70244.589771]  [<ffffffff813e0389>] redraw_screen+0x1a9/0x270
[70244.591791]  [<ffffffff81361c3e>] ? fb_blank+0xae/0xc0
[70244.593737]  [<ffffffff8136dbba>] fbcon_blank+0x22a/0x2f0
[70244.595662]  [<ffffffff8107e484>] ? wake_up_klogd+0x34/0x50
[70244.597544]  [<ffffffff8107e893>] ? __console_unlock+0x3f3/0x4a0
[70244.599419]  [<ffffffff8165b94e>] ? _raw_spin_lock_irqsave+0x6e/0xc0
[70244.601322]  [<ffffffff8108d883>] ? __internal_add_timer+0x113/0x130
[70244.603197]  [<ffffffff8108fe9d>] ? mod_timer+0x11d/0x230
[70244.604913]  [<ffffffff813e0a98>] do_unblank_screen+0xb8/0x1f0
[70244.606939]  [<ffffffff813e0be0>] unblank_screen+0x10/0x20
[70244.608671]  [<ffffffff8131ddd9>] bust_spinlocks+0x19/0x40
[70244.610445]  [<ffffffff8165d748>] oops_end+0x38/0x150
[70244.612155]  [<ffffffff8164c7d1>] no_context+0x28f/0x2b2
[70244.613788]  [<ffffffff8164c867>] __bad_area_nosemaphore+0x73/0x1ca
[70244.615692]  [<ffffffff81067019>] ? flush_tlb_page+0x39/0xa0
[70244.617355]  [<ffffffff8164c9d1>] bad_area_nosemaphore+0x13/0x15
[70244.619047]  [<ffffffff816609f6>] __do_page_fault+0x246/0x490
[70244.620704]  [<ffffffff81660d03>] trace_do_page_fault+0x43/0x110
[70244.622656]  [<ffffffff816603b9>] do_async_page_fault+0x29/0xe0
[70244.624372]  [<ffffffff8165c9f8>] async_page_fault+0x28/0x30
[70244.626004]  [<ffffffff810aca65>] ? down_read_trylock+0x5/0x50
[70244.627698]  [<ffffffff811b241c>] ? page_lock_anon_vma_read+0x5c/0x120
[70244.629425]  [<ffffffff811b26a7>] page_referenced+0x1c7/0x350
[70244.631047]  [<ffffffff8118d634>] shrink_active_list+0x1e4/0x400
[70244.632724]  [<ffffffff8118f088>] balance_pgdat+0x1d8/0x610
[70244.634351]  [<ffffffff8118f633>] kswapd+0x173/0x450
[70244.636030]  [<ffffffff810a89a0>] ? wake_up_atomic_t+0x30/0x30
[70244.637777]  [<ffffffff8118f4c0>] ? balance_pgdat+0x610/0x610
[70244.640320]  [<ffffffff810a795f>] kthread+0xcf/0xe0
[70244.641846]  [<ffffffff810a7890>] ? kthread_create_on_node+0x120/0x120
[70244.643545]  [<ffffffff81665398>] ret_from_fork+0x58/0x90
[70244.645096]  [<ffffffff810a7890>] ? kthread_create_on_node+0x120/0x120
[70244.646786] Code: ba 00 00 00 48 c7 c7 98 af 87 81 44 89 85 78 ff ff ff 89 4d 80 e8 09 8f 01 00 44 8b 85 78 ff ff ff 8b 4d 80 e9 c0 fd ff ff 0f 0b <0f> 0b 0f 0b 0f 1f 40 00 0f 1f 44 00 00 55 31 c0 48 89 e5 48 83
[70244.652123] RIP  [<ffffffff81063518>] change_page_attr_set_clr+0x4c8/0x4d0
[70244.653950]  RSP <ffff8801b57fee98>
[70244.655376] ---[ end trace d39a19e1be103a08 ]---
[70244.656923] Kernel panic - not syncing: Fatal exception



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
