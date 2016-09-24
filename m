Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA87E28024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:06:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so31162727wmc.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 17:06:38 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id mh12si9580249wjb.128.2016.09.23.17.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 17:06:37 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id b130so55797391wmc.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 17:06:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1609231705570.5640@nanos>
References: <alpine.DEB.2.20.1609231705570.5640@nanos>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sat, 24 Sep 2016 02:06:36 +0200
Message-ID: <CAJZ5v0iCo=23ZC5G9gBY01VxY4PpJEbQsjdfZk1fC7bVR++M8w@mail.gmail.com>
Subject: Re: acpi: Fix broken error check in map_processor()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, cl@linux.com, Tejun Heo <tj@kernel.org>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, Len Brown <lenb@kernel.org>, chen.tang@easystack.cn, "Rafael J. Wysocki" <rafael@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

On Fri, Sep 23, 2016 at 5:08 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> map_processor() checks the cpuid value returned by acpi_map_cpuid() for -1
> but acpi_map_cpuid() returns -EINVAL in case of error.
>
> As a consequence the error is ignored and the following access into percpu
> data with that negative cpuid results in a boot crash.
>
> This happens always when NR_CPUS/nr_cpu_ids is smaller than the number of
> processors listed in the ACPI tables.
>
> Use a proper error check for id < 0 so the function returns instead of
> trying to map CPU#(-EINVAL).
>
> Reported-by: Ingo Molnar <mingo@kernel.org>
> Fixes: dc6db24d2476 ("x86/acpi: Set persistent cpuid <-> nodeid mapping when booting")
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

It looks like the commit in the Fixes tag is in the tip tree now, so
the fix should better go in via tip as well IMO.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  drivers/acpi/processor_core.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -284,7 +284,7 @@ EXPORT_SYMBOL_GPL(acpi_get_cpuid);
>  static bool __init
>  map_processor(acpi_handle handle, phys_cpuid_t *phys_id, int *cpuid)
>  {
> -       int type;
> +       int type, id;
>         u32 acpi_id;
>         acpi_status status;
>         acpi_object_type acpi_type;
> @@ -320,10 +320,11 @@ map_processor(acpi_handle handle, phys_c
>         type = (acpi_type == ACPI_TYPE_DEVICE) ? 1 : 0;
>
>         *phys_id = __acpi_get_phys_id(handle, type, acpi_id, false);
> -       *cpuid = acpi_map_cpuid(*phys_id, acpi_id);
> -       if (*cpuid == -1)
> -               return false;
> +       id = acpi_map_cpuid(*phys_id, acpi_id);
>
> +       if (id < 0)
> +               return false;
> +       *cpuid = id;
>         return true;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
