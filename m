Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6598C6B0268
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:55:35 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 184so126457593pff.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:55:35 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0121.outbound.protection.outlook.com. [104.47.1.121])
        by mx.google.com with ESMTPS id dz4si4284028pab.12.2016.04.11.08.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 08:55:34 -0700 (PDT)
Subject: Re: [PATCH] x86/vdso: add mremap hook to vm_special_mapping
References: <201604112306.pt7CJqPB%fengguang.wu@intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <570BC8B1.7090303@virtuozzo.com>
Date: Mon, 11 Apr 2016 18:54:25 +0300
MIME-Version: 1.0
In-Reply-To: <201604112306.pt7CJqPB%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, luto@amacapital.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com

On 04/11/2016 06:41 PM, kbuild test robot wrote:
> Hi Dmitry,
>
> [auto build test WARNING on v4.6-rc3]
> [also build test WARNING on next-20160411]
> [cannot apply to tip/x86/vdso luto/next]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Dmitry-Safonov/x86-vdso-add-mremap-hook-to-vm_special_mapping/20160411-232653
> config: x86_64-randconfig-x000-201615 (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>     arch/x86/entry/vdso/vma.c: In function 'vdso_mremap':
>>> arch/x86/entry/vdso/vma.c:105:18: warning: unused variable 'regs' [-Wunused-variable]
>       struct pt_regs *regs = current_pt_regs();
>                       ^
Thanks, it should go with this:
--->8---
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 08ac59907cde..7e261e2554c8 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -102,7 +102,7 @@ static int vdso_fault(const struct 
vm_special_mapping *sm,
  static int vdso_mremap(const struct vm_special_mapping *sm,
                struct vm_area_struct *new_vma)
  {
-    struct pt_regs *regs = current_pt_regs();
+    struct pt_regs __maybe_unused *regs = current_pt_regs();

  #if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
      /* Fixing userspace landing - look at do_fast_syscall_32 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
