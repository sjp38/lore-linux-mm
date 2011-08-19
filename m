Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E391E6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 07:40:10 -0400 (EDT)
Received: by qyk27 with SMTP id 27so234192qyk.14
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 04:40:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312891671-28680-3-git-send-email-per.forlin@linaro.org>
References: <1312891671-28680-1-git-send-email-per.forlin@linaro.org>
	<1312891671-28680-3-git-send-email-per.forlin@linaro.org>
Date: Fri, 19 Aug 2011 13:40:08 +0200
Message-ID: <CACRpkdZjNr6Wse9A_y_8TXBGc6NNr_=-uXGsFPD2w-mhwGUcDg@mail.gmail.com>
Subject: Re: [PATCH --mmotm v8 2/3] mmc: core: add random fault injection
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>, linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org

On Tue, Aug 9, 2011 at 2:07 PM, Per Forlin <per.forlin@linaro.org> wrote:

> This adds support to inject data errors after a completed host transfer.
> The mmc core will return error even though the host transfer is successfu=
l.
> This simple fault injection proved to be very useful to test the
> non-blocking error handling in the mmc_blk_issue_rw_rq().
> Random faults can also test how the host driver handles pre_req()
> and post_req() in case of errors.

Good idea!

> diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
> index 89bdeae..a4996b0 100644
> --- a/drivers/mmc/core/core.c
> +++ b/drivers/mmc/core/core.c
> @@ -25,6 +25,11 @@
> =A0#include <linux/pm_runtime.h>
> =A0#include <linux/suspend.h>
>
> +#ifdef CONFIG_FAIL_MMC_REQUEST
> +#include <linux/fault-inject.h>
> +#include <linux/random.h>
> +#endif

You don't need to #ifdef around the #include <> stuff, and if you
do, something is wrong with those headers. It's just a bunch of defines
that aren't used in some circumstances. Stack them with the others,
simply, just #ifdef the code below.

> @@ -83,6 +88,43 @@ static void mmc_flush_scheduled_work(void)
> =A0 =A0 =A0 =A0flush_workqueue(workqueue);
> =A0}
>
> +#ifdef CONFIG_FAIL_MMC_REQUEST
> +
> +/*
> + * Internal function. Inject random data errors.
> + * If mmc_data is NULL no errors are injected.
> + */
> +static void mmc_should_fail_request(struct mmc_host *host,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct mmc_request *mrq)
> +{
> + =A0 =A0 =A0 struct mmc_command *cmd =3D mrq->cmd;
> + =A0 =A0 =A0 struct mmc_data *data =3D mrq->data;
> + =A0 =A0 =A0 static const int data_errors[] =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 -ETIMEDOUT,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 -EILSEQ,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 -EIO,
> + =A0 =A0 =A0 };
> +
> + =A0 =A0 =A0 if (!data)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (cmd->error || data->error ||
> + =A0 =A0 =A0 =A0 =A0 !should_fail(&host->fail_mmc_request, data->blksz *=
 data->blocks))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 data->error =3D data_errors[random32() % ARRAY_SIZE(data_er=
rors)];
> + =A0 =A0 =A0 data->bytes_xfered =3D (random32() % (data->bytes_xfered >>=
 9)) << 9;
> +}
> +
> +#else /* CONFIG_FAIL_MMC_REQUEST */
> +
> +static void mmc_should_fail_request(struct mmc_host *host,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct mmc_request *mrq)

Should be "static inline" so we know it will be folded in and nullified
by the compiler, lots of kernel code use that pattern.

> diff --git a/drivers/mmc/core/debugfs.c b/drivers/mmc/core/debugfs.c
> index f573753..189581d 100644
> --- a/drivers/mmc/core/debugfs.c
> +++ b/drivers/mmc/core/debugfs.c
> @@ -13,6 +13,9 @@
> =A0#include <linux/seq_file.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/stat.h>
> +#ifdef CONFIG_FAIL_MMC_REQUEST
> +#include <linux/fault-inject.h>
> +#endif

No #ifdef:ing...

> diff --git a/include/linux/mmc/host.h b/include/linux/mmc/host.h
> index 0f83858..ee472fe 100644
> --- a/include/linux/mmc/host.h
> +++ b/include/linux/mmc/host.h
> @@ -12,6 +12,9 @@
>
> =A0#include <linux/leds.h>
> =A0#include <linux/sched.h>
> +#ifdef CONFIG_FAIL_MMC_REQUEST
> +#include <linux/fault-inject.h>
> +#endif

Neither here...

> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 47879c7..ebff0c9 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug

I'm contemplating if we should create drivers/mmc/Kconfig.debug
and stash this in there instead, i.e. also move out MMC_DEBUG
from drivers/mmc/Kconfig and add to that?

It seems more apropriate to select this from the MMC subsystem.
However the core of fault injection is in lib/

So maybe a simple:

config FAIL_MMC_REQUEST
    bool
    select FAULT_INJECTION

That can then be selected by a debug option in the MMC subsystem?
I fear it may be hard to find this otherwise...

(NB: I have very little clue how the Kconfig.debug files get sourced
into the Kbuild so I might be misguided...)

> @@ -1090,6 +1090,17 @@ config FAIL_IO_TIMEOUT
> =A0 =A0 =A0 =A0 =A0Only works with drivers that use the generic timeout h=
andling,
> =A0 =A0 =A0 =A0 =A0for others it wont do anything.
>
> +config FAIL_MMC_REQUEST
> + =A0 =A0 =A0 bool "Fault-injection capability for MMC IO"
> + =A0 =A0 =A0 select DEBUG_FS
> + =A0 =A0 =A0 depends on FAULT_INJECTION && MMC

Isn't:

depends on MMC
select FAULT_INJECTION

Simpler to use? Now you have to select fault injection first
to even see this option right?

Apart from this it looks fine.

Thanks,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
