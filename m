Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 193836B0074
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:13:16 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so44387012pad.4
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:13:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm1si11525274pbb.164.2015.01.29.15.13.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:13:15 -0800 (PST)
Date: Thu, 29 Jan 2015 15:13:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 16/17] module: fix types of device tables aliases
Message-Id: <20150129151314.8b3951ff70d67cde9223f927@linux-foundation.org>
In-Reply-To: <1422544321-24232-17-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-17-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>

On Thu, 29 Jan 2015 18:12:00 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
> Normally alias should have the same type as aliased symbol.
> 
> Device tables are arrays, so they have 'struct type##_device_id[x]'
> types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
> 	'struct type##_device_id'.
> 
> This inconsistency confuses compiler, it could make a wrong
> assumption about variable's size which leads KASan to
> produce a false positive report about out of bounds access.

The changelog describes the problem but doesn't describe how the patch
addresses the problem.  Some more details would be useful.

> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
>  #ifdef MODULE
>  /* Creates an alias so file2alias.c can find device table. */
>  #define MODULE_DEVICE_TABLE(type, name)					\
> -  extern const struct type##_device_id __mod_##type##__##name##_device_table \
> +extern typeof(name) __mod_##type##__##name##_device_table \
>    __attribute__ ((unused, alias(__stringify(name))))

We lost the const?  If that's deliberate then why?  What are the
implications?  Do the device tables now go into rw memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
