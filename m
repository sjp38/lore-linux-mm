Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7433C6B035F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 17:35:27 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id y21so51277128lfa.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:35:27 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id o94si13401723lfg.22.2016.12.20.14.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 14:35:25 -0800 (PST)
Received: by mail-lf0-x22c.google.com with SMTP id t196so86030493lff.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:35:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161220210144.u47znzx6qniecuvv@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 20 Dec 2016 23:35:23 +0100
Message-ID: <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
Subject: Re: x86: warning in unwind_get_return_address
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Kostya Serebryany <kcc@google.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Dec 20, 2016 at 10:01 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Tue, Dec 20, 2016 at 03:43:27PM +0100, Andrey Konovalov wrote:
>> Hi,
>>
>> I've got the following warning while running the syzkaller fuzzer:
>>
>> WARNING: unrecognized kernel stack return address ffffffffa0000001 at
>> ffff88006377fa18 in a.out:4467
>>
>> By adding a BUG() to unwind_get_return_address() I was able to capture
>> the stack trace (see below). Looks like unwind_get_return_address()
>> gets called when KASAN tries to unwind the stack to save the stack
>> trace.
>>
>> A reproducer is attached. CONFIG_KASAN=y is most likely needed for it to work.
>
> Hi Andrey,
>
> I've tried with your reproducer but it didn't recreate.  Can you try
> again with the following patch from the tip tree, instead of your BUG()
> patch?
>
>   http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/patch/?id=8b5e99f02264130782a10ba5c0c759797fb064ee
>
> That will dump the stack data, which should give more clues about what
> went wrong.

Hi Josh,

Sure, here it is:

[   26.106079] WARNING: unrecognized kernel stack return address
ffffffffa0000000 at ffff8800646e7a28 in a.out:4232
[   26.106086] unwind stack type:1 next_sp:          (null) mask:6 graph_idx:0
[   26.106094] ffff8800646e79a8: ffff8800683e0028 (0xffff8800683e0028)
[   26.106098] ffff8800646e79b0: 0000000000000000 ...
[   26.106123] ffff8800646e79b8: ffffffff85e480c0 (dccp_v6_protosw+0x60/0x60)
[   26.106129] ffff8800646e79c0: 1ffff1000c8dcf4f (0x1ffff1000c8dcf4f)
[   26.106134] ffff8800646e79c8: ffff8800646e7b00 (0xffff8800646e7b00)
[   26.106139] ffff8800646e79d0: ffff8800683e0000 (0xffff8800683e0000)
[   26.106143] ffff8800646e79d8: 0000000000000000 ...
[   26.106147] ffff8800646e79f0: 0000000000000001 (0x1)
[   26.106153] ffff8800646e79f8: ffff88006765c200 (0xffff88006765c200)
[   26.106158] ffff8800646e7a00: 1ffffffff0bc9025 (0x1ffffffff0bc9025)
[   26.106161] ffff8800646e7a08: 0000000000000000 ...
[   26.106166] ffff8800646e7a10: ffff8800646e7e78 (0xffff8800646e7e78)
[   26.106171] ffff8800646e7a18: ffff8800683e0000 (0xffff8800683e0000)
[   26.106177] ffff8800646e7a20: ffffffffffffff10 (0xffffffffffffff10)
[   26.106182] ffff8800646e7a28: ffffffffa0000000 (0xffffffffa0000000)
[   26.106186] ffff8800646e7a30: 0000000000000010 (0x10)
[   26.106191] ffff8800646e7a38: 0000000000000246 (0x246)
[   26.106196] ffff8800646e7a40: ffff8800646e7a50 (0xffff8800646e7a50)
[   26.106201] ffff8800646e7a48: 0000000000000018 (0x18)
[   26.106212] ffff8800646e7a50: ffffffff83a987a4 (inet_sendmsg+0x164/0x5b0)
[   26.106222] ffff8800646e7a58: ffffffff81842514 (kasan_check_write+0x14/0x20)
[   26.106228] ffff8800646e7a60: ffff8800646e7c40 (0xffff8800646e7c40)
[   26.106237] ffff8800646e7a68: ffffffff8206ac89 (_copy_from_user+0x99/0x120)
[   26.106242] ffff8800646e7a70: ffff8800646e7e78 (0xffff8800646e7e78)
[   26.106247] ffff8800646e7a78: 0000000041b58ab3 (0x41b58ab3)
[   26.106257] ffff8800646e7a80: ffffffff855d9233
(__func__.54982+0x22a033/0x2d46f0)
[   26.106266] ffff8800646e7a88: ffffffff83a98640 (inet_recvmsg+0x610/0x610)
[   26.106271] ffff8800646e7a90: ffff8800659b8cc0 (0xffff8800659b8cc0)
[   26.106276] ffff8800646e7a98: ffff8800646e7e78 (0xffff8800646e7e78)
[   26.106280] ffff8800646e7aa0: 0000000000000000 ...
[   26.106285] ffff8800646e7aa8: ffff8800646e7ac0 (0xffff8800646e7ac0)
[   26.106294] ffff8800646e7ab0: ffffffff81e75f4f
(selinux_socket_sendmsg+0x3f/0x50)
[   26.106303] ffff8800646e7ab8: ffffffff85a27d00 (selinux_hooks+0x10c0/0x1560)
[   26.106308] ffff8800646e7ac0: ffff8800646e7b00 (0xffff8800646e7b00)
[   26.106317] ffff8800646e7ac8: ffffffff81e4e749
(security_socket_sendmsg+0x89/0xb0)
[   26.106322] ffff8800646e7ad0: 000000008331fbd3 (0x8331fbd3)
[   26.106337] ffff8800646e7ad8: ffff8800646e7e78 (0xffff8800646e7e78)
[   26.106343] ffff8800646e7ae0: ffffffff83a98640 (inet_recvmsg+0x610/0x610)
[   26.106347] ffff8800646e7ae8: ffff8800659b8cc0 (0xffff8800659b8cc0)
[   26.106350] ffff8800646e7af0: ffff8800646e7e98 (0xffff8800646e7e98)
[   26.106354] ffff8800646e7af8: ffff8800646e7be0 (0xffff8800646e7be0)
[   26.106358] ffff8800646e7b00: ffff8800646e7b30 (0xffff8800646e7b30)
[   26.106365] ffff8800646e7b08: ffffffff8331de8a (sock_sendmsg+0xca/0x110)
[   26.106369] ffff8800646e7b10: ffff8800646e7c40 (0xffff8800646e7c40)
[   26.106373] ffff8800646e7b18: ffff8800646e7e78 (0xffff8800646e7e78)
[   26.106376] ffff8800646e7b20: ffff8800649aca00 (0xffff8800649aca00)
[   26.106380] ffff8800646e7b28: 0000000000000040 (0x40)
[   26.106392] ffff8800646e7b30: ffff8800646e7da8 (0xffff8800646e7da8)
[   26.106399] ffff8800646e7b38: ffffffff833207d2 (___sys_sendmsg+0x9d2/0xae0)
[   26.106402] ffff8800646e7b40: ffff8800646e7eb8 (0xffff8800646e7eb8)
[   26.106405] ffff8800646e7b48: 0000000000000000 ...
[   26.106408] ffff8800646e7b58: ffff8800646e7be0 (0xffff8800646e7be0)
[   26.106412] ffff8800646e7b60: 1ffff1000c8dcf70 (0x1ffff1000c8dcf70)
[   26.106416] ffff8800646e7b68: ffff8800659b8cc0 (0xffff8800659b8cc0)
[   26.106419] ffff8800646e7b70: ffff8800646e7ce0 (0xffff8800646e7ce0)
[   26.106423] ffff8800646e7b78: ffff8800646e7ba0 (0xffff8800646e7ba0)
[   26.106427] ffff8800646e7b80: 0000000041b58ab3 (0x41b58ab3)
[   26.106433] ffff8800646e7b88: ffffffff856a04f0
(_fw_yam_9600_bin_name+0x1cb68/0x5d928)
[   26.106440] ffff8800646e7b90: ffffffff8331fe00
(copy_msghdr_from_user+0x550/0x550)
[   26.106447] ffff8800646e7b98: ffffffff8141f810 (lock_acquire+0x580/0x580)
[   26.106449] ffff8800646e7ba0: 0000000000000000 ...
[   26.106453] ffff8800646e7ba8: dead000000000100 (0xdead000000000100)
[   26.106457] ffff8800646e7bb0: 000077ff80000000 (0x77ff80000000)
[   26.106461] ffff8800646e7bb8: ffff8800646e7bd0 (0xffff8800646e7bd0)
[   26.106469] ffff8800646e7bc0: ffffffff84c29b32 (_raw_spin_unlock+0x22/0x30)
[   26.106473] ffff8800646e7bc8: ffff88006bb64bb0 (0xffff88006bb64bb0)
[   26.106477] ffff8800646e7bd0: ffff88006bb64bb0 (0xffff88006bb64bb0)
[   26.106480] ffff8800646e7bd8: ffff8800696822e8 (0xffff8800696822e8)
[   26.106484] ffff8800646e7be0: ffff8800646e7d40 (0xffff8800646e7d40)
[   26.106488] ffff8800646e7be8: ffff880064974020 (0xffff880064974020)
[   26.106492] ffff8800646e7bf0: ffff8800696822e8 (0xffff8800696822e8)
[   26.106495] ffff8800646e7bf8: ffff8800646e7c10 (0xffff8800646e7c10)
[   26.106502] ffff8800646e7c00: ffffffff84c29b32 (_raw_spin_unlock+0x22/0x30)
[   26.106505] ffff8800646e7c08: ffff8800646e7cc0 (0xffff8800646e7cc0)
[   26.106509] ffff8800646e7c10: ffff8800646e7d68 (0xffff8800646e7d68)
[   26.106515] ffff8800646e7c18: ffffffff817bae1b (handle_mm_fault+0xafb/0x1f30)
[   26.106519] ffff8800646e7c20: 0000000064974067 (0x64974067)
[   26.106522] ffff8800646e7c28: ffff8800678f0580 (0xffff8800678f0580)
[   26.106526] ffff8800646e7c30: 8000000062b56067 (0x8000000062b56067)
[   26.106533] ffff8800646e7c38: ffffffff818d8a2a (__fget_light+0x2aa/0x3e0)
[   26.106537] ffff8800646e7c40: ffff880066711e58 (0xffff880066711e58)
[   26.106540] ffff8800646e7c48: 0000400000000000 (0x400000000000)
[   26.106544] ffff8800646e7c50: 0000000041b58ab3 (0x41b58ab3)
[   26.106550] ffff8800646e7c58: ffffffff855e6380
(__func__.54982+0x237180/0x2d46f0)
[   26.106556] ffff8800646e7c60: ffffffff818d8780 (fget_raw+0x20/0x20)
[   26.106562] ffff8800646e7c68: ffffffff856104ba
(__func__.54982+0x2612ba/0x2d46f0)
[   26.106566] ffff8800646e7c70: ffffffff00000001 (0xffffffff00000001)
[   26.106569] ffff8800646e7c78: 0000000041b58ab3 (0x41b58ab3)
[   26.106572] ffff8800646e7c80: 0000000000000000 ...
[   26.106577] ffff8800646e7c88: ffffffff81410f40 (__lock_is_held+0x140/0x140)
[   26.106581] ffff8800646e7c90: 0000000000000003 (0x3)
[   26.106585] ffff8800646e7c98: ffff8800678f0620 (0xffff8800678f0620)
[   26.106588] ffff8800646e7ca0: 1ffff1000c8dcf9c (0x1ffff1000c8dcf9c)
[   26.106591] ffff8800646e7ca8: 0000000000000001 (0x1)
[   26.106595] ffff8800646e7cb0: ffff880066711e58 (0xffff880066711e58)
[   26.106599] ffff8800646e7cb8: ffff8800678f0678 (0xffff8800678f0678)
[   26.106602] ffff8800646e7cc0: ffff8800696822e8 (0xffff8800696822e8)
[   26.106606] ffff8800646e7cc8: 024000c000000055 (0x24000c000000055)
[   26.106610] ffff8800646e7cd0: 0000000000020004 (0x20004)
[   26.106613] ffff8800646e7cd8: 0000000020004000 (0x20004000)
[   26.106617] ffff8800646e7ce0: ffff8800662d0000 (0xffff8800662d0000)
[   26.106619] ffff8800646e7ce8: 0000000000000000 ...
[   26.106623] ffff8800646e7cf0: ffff8800649aca00 (0xffff8800649aca00)
[   26.106625] ffff8800646e7cf8: 0000000000000000 ...
[   26.106629] ffff8800646e7d08: ffff880064974020 (0xffff880064974020)
[   26.106633] ffff8800646e7d10: ffff88006bb64bb0 (0xffff88006bb64bb0)
[   26.106635] ffff8800646e7d18: 0000000000000000 ...
[   26.106638] ffff8800646e7d20: 0000000020004fc8 (0x20004fc8)
[   26.106642] ffff8800646e7d28: ffff8800678f0620 (0xffff8800678f0620)
[   26.106645] ffff8800646e7d30: 0000000000000003 (0x3)
[   26.106649] ffff8800646e7d38: ffff8800646e7e38 (0xffff8800646e7e38)
[   26.106653] ffff8800646e7d40: ffff8800646e7e38 (0xffff8800646e7e38)
[   26.106656] ffff8800646e7d48: ffff8800646e7df8 (0xffff8800646e7df8)
[   26.106660] ffff8800646e7d50: 1ffff1000c8dcfbb (0x1ffff1000c8dcfbb)
[   26.106664] ffff8800646e7d58: ffff8800646e7d70 (0xffff8800646e7d70)
[   26.106670] ffff8800646e7d60: ffffffff818d8b78 (__fdget+0x18/0x20)
[   26.106673] ffff8800646e7d68: 0000000000000003 (0x3)
[   26.106677] ffff8800646e7d70: ffff8800646e7da8 (0xffff8800646e7da8)
[   26.106683] ffff8800646e7d78: ffffffff8331ac04
(sockfd_lookup_light+0x104/0x150)
[   26.106687] ffff8800646e7d80: ffff8800646e7ef8 (0xffff8800646e7ef8)
[   26.106690] ffff8800646e7d88: ffffed000c8dcfc7 (0xffffed000c8dcfc7)
[   26.106694] ffff8800646e7d90: ffff8800646e7e38 (0xffff8800646e7e38)
[   26.106698] ffff8800646e7d98: ffff8800659b8cc0 (0xffff8800659b8cc0)
[   26.106702] ffff8800646e7da0: 1ffff1000c8dcfbb (0x1ffff1000c8dcfbb)
[   26.106705] ffff8800646e7da8: ffff8800646e7f20 (0xffff8800646e7f20)
[   26.106712] ffff8800646e7db0: ffffffff83323428 (__sys_sendmsg+0x138/0x320)
[   26.106715] ffff8800646e7db8: ffff8800646e7df8 (0xffff8800646e7df8)
[   26.106719] ffff8800646e7dc0: 0000000041b58ab3 (0x41b58ab3)
[   26.106722] ffff8800646e7dc8: 0000000020004fc8 (0x20004fc8)
[   26.106726] ffff8800646e7dd0: ffffffff00000003 (0xffffffff00000003)
[   26.106729] ffff8800646e7dd8: 0000000041b58ab3 (0x41b58ab3)
[   26.106736] ffff8800646e7de0: ffffffff856a0598
(_fw_yam_9600_bin_name+0x1cc10/0x5d928)
[   26.106742] ffff8800646e7de8: ffffffff833232f0 (SyS_shutdown+0x2f0/0x2f0)
[   26.106745] ffff8800646e7df0: 0000000041b58ab3 (0x41b58ab3)
[   26.106749] ffff8800646e7df8: ffffffff00000000 (0xffffffff00000000)
[   26.106756] ffff8800646e7e00: ffffffff8128f720 (do_page_fault+0x30/0x30)
[   26.106759] ffff8800646e7e08: ffff88006bc74a20 (0xffff88006bc74a20)
[   26.106763] ffff8800646e7e10: ffff88006c03adc0 (0xffff88006c03adc0)
[   26.106767] ffff8800646e7e18: ffff8800646e7e60 (0xffff8800646e7e60)
[   26.106771] ffff8800646e7e20: ffff88006765c200 (0xffff88006765c200)
[   26.106774] ffff8800646e7e28: 0000000000000003 (0x3)
[   26.106777] ffff8800646e7e30: ffff8800649aca00 (0xffff8800649aca00)
[   26.106781] ffff8800646e7e38: ffff8800fffffff7 (0xffff8800fffffff7)
[   26.106784] ffff8800646e7e40: 0000000000000000 ...
[   26.106787] ffff8800646e7e48: 0000000000000802 (0x802)
[   26.106790] ffff8800646e7e50: 0000000041b58ab3 (0x41b58ab3)
[   26.106796] ffff8800646e7e58: ffffffff855e2f80
(__func__.54982+0x233d80/0x2d46f0)
[   26.106802] ffff8800646e7e60: ffffffff8140d720
(trace_raw_output_lock+0x190/0x190)
[   26.106806] ffff8800646e7e68: ffff8800659b8cc0 (0xffff8800659b8cc0)
[   26.106810] ffff8800646e7e70: ffff8800646e7e98 (0xffff8800646e7e98)
[   26.106814] ffff8800646e7e78: ffff8800646e7ce0 (0xffff8800646e7ce0)
[   26.106817] ffff8800646e7e80: ffff880000000002 (0xffff880000000002)
[   26.106821] ffff8800646e7e88: 1ffff10000000001 (0x1ffff10000000001)
[   26.106823] ffff8800646e7e90: 0000000000000000 ...
[   26.106827] ffff8800646e7ea0: ffff8800646e7c40 (0xffff8800646e7c40)
[   26.106829] ffff8800646e7ea8: 0000000000000000 ...
[   26.106833] ffff8800646e7eb0: 0000000020005000 (0x20005000)
[   26.106835] ffff8800646e7eb8: 0000000000000000 ...
[   26.106838] ffff8800646e7ec0: 0000000000000040 (0x40)
[   26.106840] ffff8800646e7ec8: 0000000000000000 ...
[   26.106844] ffff8800646e7ed0: 0000000000400ff0 (0x400ff0)
[   26.106847] ffff8800646e7ed8: 00007ffcbbc601b0 (0x7ffcbbc601b0)
[   26.106850] ffff8800646e7ee0: 0000000000000000 ...
[   26.106853] ffff8800646e7ef0: ffff8800646e7f48 (0xffff8800646e7f48)
[   26.106856] ffff8800646e7ef8: 0000000000000000 ...
[   26.106859] ffff8800646e7f00: 0000000000000003 (0x3)
[   26.106864] ffff8800646e7f08: 0000000020004fc8 (0x20004fc8)
[   26.106867] ffff8800646e7f10: 0000000000000000 ...
[   26.106870] ffff8800646e7f20: ffff8800646e7f48 (0xffff8800646e7f48)
[   26.106877] ffff8800646e7f28: ffffffff8332363d (SyS_sendmsg+0x2d/0x50)
[   26.106879] ffff8800646e7f30: 0000000000000000 ...
[   26.106882] ffff8800646e7f38: 0000000000400ff0 (0x400ff0)
[   26.106887] ffff8800646e7f40: 00007ffcbbc601b0 (0x7ffcbbc601b0)
[   26.106893] ffff8800646e7f48: 00007ffcbbc5ff30 (0x7ffcbbc5ff30)
[   26.106903] ffff8800646e7f50: ffffffff84c2a881
(entry_SYSCALL_64_fastpath+0x1f/0xc2)
[   26.106907] ffff8800646e7f58: 0000000000000000 ...
[   26.106913] ffff8800646e7f68: 00007ffcbbc601b0 (0x7ffcbbc601b0)
[   26.106917] ffff8800646e7f70: 0000000000000000 ...
[   26.106923] ffff8800646e7f78: 0000000000400ff0 (0x400ff0)
[   26.106930] ffff8800646e7f80: 00007ffcbbc601b0 (0x7ffcbbc601b0)
[   26.106936] ffff8800646e7f88: 0000000000000206 (0x206)
[   26.106940] ffff8800646e7f90: 0000000000000000 ...
[   26.106946] ffff8800646e7fa8: ffffffffffffffda (0xffffffffffffffda)
[   26.106953] ffff8800646e7fb0: 00007f6ca65f4b79 (0x7f6ca65f4b79)
[   26.106957] ffff8800646e7fb8: 0000000000000000 ...
[   26.106963] ffff8800646e7fc0: 0000000020004fc8 (0x20004fc8)
[   26.106968] ffff8800646e7fc8: 0000000000000003 (0x3)
[   26.106974] ffff8800646e7fd0: 000000000000002e (0x2e)
[   26.106980] ffff8800646e7fd8: 00007f6ca65f4b79 (0x7f6ca65f4b79)
[   26.106986] ffff8800646e7fe0: 0000000000000033 (0x33)
[   26.106989] ffff8800646e7fe8: 0000000000000206 (0x206)
[   26.106992] ffff8800646e7ff0: 00007ffcbbc5fee8 (0x7ffcbbc5fee8)
[   26.106996] ffff8800646e7ff8: 000000000000002b (0x2b)

Thanks!

>
> --
> Josh
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20161220210144.u47znzx6qniecuvv%40treble.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
