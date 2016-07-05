Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1B6A6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 01:57:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so79607333wme.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 22:57:38 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id i142si1778650wmf.68.2016.07.04.22.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 22:57:37 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so26056069wmz.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 22:57:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <263e604d-aa8c-1b6b-e80a-0c34142349c9@intel.com>
References: <20160429083408.GA20728@aaronlu.sh.intel.com> <263e604d-aa8c-1b6b-e80a-0c34142349c9@intel.com>
From: Yu Chen <yu.chen.surf@gmail.com>
Date: Tue, 5 Jul 2016 13:57:35 +0800
Message-ID: <CADjb_WQGuUULfiMhY3LzwcMUyFa7XcuF6vbgEXcRP2iFNh3TXQ@mail.gmail.com>
Subject: Re: [RFC RESEND PATCH] swap: choose swap device according to numa node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jul 5, 2016 at 11:19 AM, Aaron Lu <aaron.lu@intel.com> wrote:
> Resend:
> This is a resend, the original patch doesn't catch much attention.
> It may not be a big deal for swap devices that used to be hosted on
> HDD but with devices like 3D Xpoint to be used as swap device, it could
> make a real difference if we consider NUMA information when doing IO.
> Comments are appreciated, thanks for your time.
>
-------------------------%<-------------------------
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 71b1c29948db..dd7e44a315b0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3659,9 +3659,11 @@ void kswapd_stop(int nid)
>
>  static int __init kswapd_init(void)
>  {
> -       int nid;
> +       int nid, err;
>
> -       swap_setup();
> +       err = swap_setup();
> +       if (err)
> +               return err;
>         for_each_node_state(nid, N_MEMORY)
>                 kswapd_run(nid);
>         hotcpu_notifier(cpu_callback, 0);
In original implementation, although swap_setup failed,
the swapd would also be created, since swapd is
not only  used for swap out but also for other page reclaim,
so this change above might modify its semantic? Sorry if
I understand incorrectly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
