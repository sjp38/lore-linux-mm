Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBCA6B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 19:23:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f11so6133185oic.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 16:23:18 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id 138si1477249oia.62.2017.08.16.16.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 16:23:17 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id j32so18130672iod.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 16:23:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816231458.2299-3-labbott@redhat.com>
References: <20170816231458.2299-1-labbott@redhat.com> <20170816231458.2299-3-labbott@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 16 Aug 2017 16:23:16 -0700
Message-ID: <CAGXu5j+orJe-6FzZvuOiZQKM+_vnwjVmN_5_KP7+LJH_-h0MZg@mail.gmail.com>
Subject: Re: [PATCHv3 2/2] extract early boot entropy from the passed cmdline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Daniel Micay <danielmicay@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 16, 2017 at 4:14 PM, Laura Abbott <labbott@redhat.com> wrote:
> From: Daniel Micay <danielmicay@gmail.com>
>
>
> Existing Android bootloaders usually pass data useful as early entropy
> on the kernel command-line. It may also be the case on other embedded
> systems. Sample command-line from a Google Pixel running CopperheadOS:
>
>     console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0
>     androidboot.hardware=sailfish user_debug=31 ehci-hcd.park=3
>     lpm_levels.sleep_disabled=1 cma=32M@0-0xffffffff buildvariant=user
>     veritykeyid=id:dfcb9db0089e5b3b4090a592415c28e1cb4545ab
>     androidboot.bootdevice=624000.ufshc androidboot.verifiedbootstate=yellow
>     androidboot.veritymode=enforcing androidboot.keymaster=1
>     androidboot.serialno=FA6CE0305299 androidboot.baseband=msm
>     mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_samsung_ea8064tg_1080p_cmd:1:none:cfg:single_dsi
>     androidboot.slot_suffix=_b fpsimd.fpsimd_settings=0
>     app_setting.use_app_setting=0 kernelflag=0x00000000 debugflag=0x00000000
>     androidboot.hardware.revision=PVT radioflag=0x00000000
>     radioflagex1=0x00000000 radioflagex2=0x00000000 cpumask=0x00000000
>     androidboot.hardware.ddr=4096MB,Hynix,LPDDR4 androidboot.ddrinfo=00000006
>     androidboot.ddrsize=4GB androidboot.hardware.color=GRA00
>     androidboot.hardware.ufs=32GB,Samsung androidboot.msm.hw_ver_id=268824801
>     androidboot.qf.st=2 androidboot.cid=11111111 androidboot.mid=G-2PW4100
>     androidboot.bootloader=8996-012001-1704121145
>     androidboot.oem_unlock_support=1 androidboot.fp_src=1
>     androidboot.htc.hrdump=detected androidboot.ramdump.opt=mem@2g:2g,mem@4g:2g
>     androidboot.bootreason=reboot androidboot.ramdump_enable=0 ro
>     root=/dev/dm-0 dm="system none ro,0 1 android-verity /dev/sda34"
>     rootwait skip_initramfs init=/init androidboot.wificountrycode=US
>     androidboot.boottime=1BLL:85,1BLE:669,2BLL:0,2BLE:1777,SW:6,KL:8136
>
> Among other things, it contains a value unique to the device
> (androidboot.serialno=FA6CE0305299), unique to the OS builds for the
> device variant (veritykeyid=id:dfcb9db0089e5b3b4090a592415c28e1cb4545ab)
> and timings from the bootloader stages in milliseconds
> (androidboot.boottime=1BLL:85,1BLE:669,2BLL:0,2BLE:1777,SW:6,KL:8136).
>
> Signed-off-by: Daniel Micay <danielmicay@gmail.com>
> [labbott: Line-wrapped command line]
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Acked-by: Kees Cook <keescook@chromium.org>

Thanks!

-Kees

> ---
> v3: add_device_randomness comes before canary initialization, clarified comment.
> ---
>  init/main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/init/main.c b/init/main.c
> index 21d599eaad06..ba2b3a8a2382 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -530,8 +530,10 @@ asmlinkage __visible void __init start_kernel(void)
>         setup_arch(&command_line);
>         /*
>          * Set up the the initial canary and entropy after arch
> +        * and after adding latent and command line entropy.
>          */
>         add_latent_entropy();
> +       add_device_randomness(command_line, strlen(command_line));
>         boot_init_stack_canary();
>         mm_init_cpumask(&init_mm);
>         setup_command_line(command_line);
> --
> 2.13.0
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
