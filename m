Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10B296B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:27:33 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 134so899951ioo.22
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 02:27:33 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id d93si6506000ioj.24.2017.11.15.02.27.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 02:27:31 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 05/11] Disable kasan's instrumentation
Date: Wed, 15 Nov 2017 10:19:09 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0063538@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-6-liuwenliang@huawei.com>
 <20171019124714.GZ20805@n2100.armlinux.org.uk>
In-Reply-To: <20171019124714.GZ20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 19/10/17 20:47, Russell King - ARM Linux [mailto:linux@armlinux.org.uk] =
 wrote:
>On Wed, Oct 11, 2017 at 04:22:21PM +0800, Abbott Liu wrote:
>> From: Andrey Ryabinin <a.ryabinin@samsung.com>
>>=20
>>  To avoid some build and runtime errors, compiler's instrumentation must
>>  be disabled for code not linked with kernel image.
>
>How does that explain the change to unwind.c ?

Thanks for your review.
Here is patch code:
--- a/arch/arm/kernel/unwind.c
+++ b/arch/arm/kernel/unwind.c
@@ -249,7 +249,8 @@ static int unwind_pop_register(struct unwind_ctrl_block=
 *ctrl,
                if (*vsp >=3D (unsigned long *)ctrl->sp_high)
                        return -URC_FAILURE;

-       ctrl->vrs[reg] =3D *(*vsp)++;
+       ctrl->vrs[reg] =3D READ_ONCE_NOCHECK(*(*vsp));
+       (*vsp)++;
        return URC_OK;
 }

I change here because I don't think unwind_frame need to be check by kasan,=
 and I have ever=20
found the following error which rarely appares when remove the change of un=
wind.c.

Here is the error log:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: KASAN: stack-out-of-bounds in unwind_frame+0x3e0/0x788
Read of size 4 at addr 868a3b20 by task swapper/0/1

CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.13.0-rc2+ #2
Hardware name: ARM-Versatile Express
[<8011479c>] (unwind_backtrace) from [<8010f558>] (show_stack+0x10/0x14)
[<8010f558>] (show_stack) from [<808fdca0>] (dump_stack+0x90/0xa4)
[<808fdca0>] (dump_stack) from [<802b3808>] (print_address_description+0x4c=
/0x270)
[<802b3808>] (print_address_description) from [<802b3ec4>] (kasan_report+0x=
218/0x300)
[<802b3ec4>] (kasan_report) from [<801143f4>] (unwind_frame+0x3e0/0x788)
[<801143f4>] (unwind_frame) from [<8010ebc4>] (walk_stackframe+0x2c/0x38)
[<8010ebc4>] (walk_stackframe) from [<8010ee70>] (__save_stack_trace+0x160/=
0x164)
[<8010ee70>] (__save_stack_trace) from [<802b342c>] (kasan_slab_free+0x84/0=
x158)
[<802b342c>] (kasan_slab_free) from [<802b05dc>] (kmem_cache_free+0x58/0x1d=
4)
[<802b05dc>] (kmem_cache_free) from [<801a6420>] (rcu_process_callbacks+0x6=
00/0xe04)
[<801a6420>] (rcu_process_callbacks) from [<801018e8>] (__do_softirq+0x1a0/=
0x4e0)
[<801018e8>] (__do_softirq) from [<80131560>] (irq_exit+0xec/0x120)
[<80131560>] (irq_exit) from [<8018d2a0>] (__handle_domain_irq+0x78/0xdc)
[<8018d2a0>] (__handle_domain_irq) from [<80101700>] (gic_handle_irq+0x48/0=
x8c)
[<80101700>] (gic_handle_irq) from [<80110690>] (__irq_svc+0x70/0x94)
Exception stack(0x868a39f0 to 0x868a3a38)
39e0:                                     7fffffff 868a3b88 00000000 000000=
01
3a00: 868a3b84 7fffffff 868a3b88 6fd1474c 868a3ac0 868a0000 00000002 868980=
00
3a20: 00000001 868a3a40 8091b4d4 8091edb0 60000013 ffffffff
[<80110690>] (__irq_svc) from [<8091edb0>] (schedule_timeout+0x0/0x3c4)
[<8091edb0>] (schedule_timeout) from [<6fd14770>] (0x6fd14770)

The buggy address belongs to the page:
page:87fcc460 count:0 mapcount:0 mapping:  (null) index:0x0
flags: 0x0()
raw: 00000000 00000000 00000000 ffffffff 00000000 87fcc474 87fcc474 0000000=
0
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 868a3a00: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
 868a3a80: 00 00 04 f4 f3 f3 f3 f3 00 00 00 00 00 00 00 00
>868a3b00: 00 00 00 00 f1 f1 f1 f1 04 f4 f4 f4 f2 f2 f2 f2
                       ^
 868a3b80: 00 00 00 00 00 04 f4 f4 f3 f3 f3 f3 00 00 00 00
 868a3c00: 00 00 00 00 f1 f1 f1 f1 00 07 f4 f4 f3 f3 f3 f3
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Disabling lock debugging due to kernel taint

/* Before poping a register check whether it is feasible or not */
static int unwind_pop_register(struct unwind_ctrl_block *ctrl,
				unsigned long **vsp, unsigned int reg)
{
	if (unlikely(ctrl->check_each_pop))
		if (*vsp >=3D (unsigned long *)ctrl->sp_high)
			return -URC_FAILURE;

	// unwind_frame+0x3e0/0x788 is here
	ctrl->vrs[reg] =3D *(*vsp)++;
	return URC_OK;
}
>
>Does this also disable the string macro changes?
>
>In any case, this should certainly precede patch 4, and very probably
>patch 2.

You are right. I will change it in net version.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
