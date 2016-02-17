Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id 604706B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:40:49 -0500 (EST)
Received: by mail-yw0-f177.google.com with SMTP id g127so1019592ywf.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:40:49 -0800 (PST)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id y68si15513804ywa.150.2016.02.16.16.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 16:40:48 -0800 (PST)
Received: by mail-yw0-x234.google.com with SMTP id u200so1069275ywf.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:40:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
References: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
Date: Tue, 16 Feb 2016 16:40:48 -0800
Message-ID: <CAPcyv4jziaJokaG_MSR7CWjOKswS9vbZTeZqOLf_9YP+=p0+MQ@mail.gmail.com>
Subject: Re: [PATCH] devm_memremap_release: fix memremap'd addr handling
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Feb 16, 2016 at 8:30 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
> The pmem driver calls devm_memremap() to map a persistent memory
> range.  When the pmem driver is unloaded, this memremap'd range
> is not released.
>
> Fix devm_memremap_release() to handle a given memremap'd address
> properly.
>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  kernel/memremap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 2c468de..7a1b5c3 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -114,7 +114,7 @@ EXPORT_SYMBOL(memunmap);
>
>  static void devm_memremap_release(struct device *dev, void *res)
>  {
> -       memunmap(res);
> +       memunmap(*(void **)res);
>  }

Ugh, yup.  Thanks Toshi!

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
