Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E5BBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0112173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:38:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="SLbzoMMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0112173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F498E0003; Tue, 12 Mar 2019 19:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE2F8E0002; Tue, 12 Mar 2019 19:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DDA98E0003; Tue, 12 Mar 2019 19:38:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48F748E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 19:38:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q15so39600pgv.22
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:38:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=PU775P2DQwgKsZzzul90rUNaMx21fIcIS+/gjK9d6BA=;
        b=HfeRUD74MovV4Xnug7rbblJ7z1EhjMH5VrKbfgnS/8OJfZ8jy9vpZlQzXWgYmVGa7I
         G4iGHHbHJYoGaIF3sq5DSMum5g/io2sO50ruulKw/5G9gvYcLCT+pz24ANWOZ0f+FHUR
         c2cpqJad/GecP9jatUtltIrmcJ0iT5sm/iuhB2onrtnIwlJAVNRTzkVeZMeqw9ABoD9w
         QhMycXIQNd0Tlk9P9IQkhF8blBPE+nUA3Pz5IVfxBwOdXkVigXDrRIdIUgektBaMkf8F
         XGUNObkgTU12LgWNMlwBgn4+JfUpeXhAJGzLFOUzPiL0ve4uBltO9VoGrysBNgh+8m5V
         9GWg==
X-Gm-Message-State: APjAAAVLa0NnnScKEt5vaFcsimKdjhBWmj0WUdz+mcZZvAISKOj0+ClT
	55KRTNqm1F54EkpJuGGlk2ESUV0Y1x3dm1c5p4I32IFpJdZuYbJCNhggL/3twxjAb+WpuysQ4F2
	y0z1pBIAsdA89/ZyQf0pUY2+b7Br9aoIsj3sik1d+ukXJYsrgxr7kNmmlEwovTSMLIXWw2/UHeg
	ybV2QAJ03K1+BlVdFMtaelr7TLnIUQOsKCOgUKOhFeLKMs7Gt2JpHEJCVVHsGczoDqC8zHpBWgf
	U6IAxPrHX+jYHuRzac0RdR2k37KyJAq0kjp0wx5GpzMFsuV9x0AA4j9RIJx9usvH8Nq6Rc/PGpF
	yRD7OGkLtIgDiaUQmwTVstvDXxOskQ6xbXjl39nfw39aQPCIZNrLFGGvBB2FbRc+pTZhket2PEv
	X
X-Received: by 2002:a17:902:547:: with SMTP id 65mr42521424plf.242.1552433912811;
        Tue, 12 Mar 2019 16:38:32 -0700 (PDT)
X-Received: by 2002:a17:902:547:: with SMTP id 65mr42521343plf.242.1552433911302;
        Tue, 12 Mar 2019 16:38:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552433911; cv=none;
        d=google.com; s=arc-20160816;
        b=hnlcC+u5uZwlFTHkWfGyd5uFwmCDzTyv8z2ba+YCsbbAAm005JJS1Avw9qAJHiuSql
         Tnj3hRM2J3oQWY3S8zk23L40lXnQbnO8NJlmBJLY0mbcj8LtxSC3x7+p5R7pATQOrBH+
         sdp0r5A5zb+JOzb4ve4+WdReOaiK9Oui6eoBkCIEvNwCDVrX4oAl7mm9glhHbcRvFZoK
         N9i+LKZnJ5xFY/fOU5e3wbQsnTTEM7VmSc8IvAd5e2nzNgrwRoteKaBc9OBODo1Bx+8D
         IofjYCLbOPOOAxZZ6cOHxdYWrHDgepekIVvWFkItBDUTxQLZtVrEHLe8sRfXhwS9C2s9
         jHrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=PU775P2DQwgKsZzzul90rUNaMx21fIcIS+/gjK9d6BA=;
        b=IH1/Ii9btD2dS/ru2OUe50VbQTRRKcpUQQP3KuZVUaB+mPM3QMIwFf8HlZzbUuyRqf
         4laZqVapoztSNRanyOhpBKQ9s7r2Y4FposAoNIwnx2KPmYDvLmVgLb/q1z/UGDi+n5QI
         rpX0tjMpTTZ3OtsB4W9Q6B6yrmOO39E4VZv368xl11VXo7m5tqodjdJWQLvn5CeUcGLe
         /By0HvNZoN7dfkt4Ow3LgXj4OUjzS3xDhXB5x1ACqtn1Hp9vBCOrYWo/VC56sIhqHQQH
         rvH0oWwp4oA71rjO7VX+XTwrsFn9CcAS8xepflJ10pG7dLsUSmgISrjcYBB6w2y5LzV+
         QTag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=SLbzoMMg;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6sor15794394pls.18.2019.03.12.16.38.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 16:38:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=SLbzoMMg;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=PU775P2DQwgKsZzzul90rUNaMx21fIcIS+/gjK9d6BA=;
        b=SLbzoMMgLWAiIe7bC31r+X1um1+wY2DBOLnI+dEY9sHH4wy2RVIxXaZSBIzDOzexUQ
         7Z2CBD0ef96y9lnPZ4qDf+Obqnadt7MyvX7d5xsMJbP6ofYetdarHEurXowpORJrexno
         EeSakB6Bn+P5KO4vcdQpUZTPzOorxUMmvLl/0=
X-Google-Smtp-Source: APXvYqzp7UKXp98ftxUglKEJfRtHdxAHPgmpIXl33ZlioVgoCRFi0CKcey5UC+rnKQMxMQ6nPNwjuw==
X-Received: by 2002:a17:902:e192:: with SMTP id cd18mr43333055plb.309.1552433910704;
        Tue, 12 Mar 2019 16:38:30 -0700 (PDT)
Received: from localhost (124-171-102-1.dyn.iinet.net.au. [124.171.102.1])
        by smtp.gmail.com with ESMTPSA id j1sm12364911pgp.84.2019.03.12.16.38.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 16:38:29 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v10 05/18] powerpc/prom_init: don't use string functions from lib/
In-Reply-To: <dc2eb0480f2c87316561435cfcf4c78254d2166b.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr> <dc2eb0480f2c87316561435cfcf4c78254d2166b.1552428161.git.christophe.leroy@c-s.fr>
Date: Wed, 13 Mar 2019 10:38:26 +1100
Message-ID: <87ftrracjx.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christophe,

In trying to extend my KASAN implementation to Book3S 64bit, I found one
other change needed to prom_init. I don't know if you think it should go
in this patch, the next one, or somewhere else entirely - I will leave
it up to you. Just let me know if you want me to carry it separately.

Thanks again for all your work on this and the integration of my series.

Regards,
Daniel

diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
index 7017156168e8..cebb3fc535ba 100644
--- a/arch/powerpc/kernel/prom_init.c
+++ b/arch/powerpc/kernel/prom_init.c
@@ -1265,7 +1265,8 @@ static void __init prom_check_platform_support(void)
                                       "ibm,arch-vec-5-platform-support");
 
        /* First copy the architecture vec template */
-       ibm_architecture_vec = ibm_architecture_vec_template;
+       memcpy(&ibm_architecture_vec, &ibm_architecture_vec_template,
+              sizeof(struct ibm_arch_vec));
 
        if (prop_len > 1) {
                int i;

> When KASAN is active, the string functions in lib/ are doing the
> KASAN checks. This is too early for prom_init.
>
> This patch implements dedicated string functions for prom_init,
> which will be compiled in with KASAN disabled.
>
> Size of prom_init before the patch:
>    text	   data	    bss	    dec	    hex	filename
>   12060	    488	   6960	  19508	   4c34	arch/powerpc/kernel/prom_init.o
>
> Size of prom_init after the patch:
>    text	   data	    bss	    dec	    hex	filename
>   12460	    488	   6960	  19908	   4dc4	arch/powerpc/kernel/prom_init.o
>
> This increases the size of prom_init a bit, but as prom_init is
> in __init section, it is freed after boot anyway.
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  arch/powerpc/kernel/prom_init.c        | 211 ++++++++++++++++++++++++++-------
>  arch/powerpc/kernel/prom_init_check.sh |   2 +-
>  2 files changed, 171 insertions(+), 42 deletions(-)
>
> diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
> index ecf083c46bdb..7017156168e8 100644
> --- a/arch/powerpc/kernel/prom_init.c
> +++ b/arch/powerpc/kernel/prom_init.c
> @@ -224,6 +224,135 @@ static bool  __prombss rtas_has_query_cpu_stopped;
>  #define PHANDLE_VALID(p)	((p) != 0 && (p) != PROM_ERROR)
>  #define IHANDLE_VALID(i)	((i) != 0 && (i) != PROM_ERROR)
>  
> +/* Copied from lib/string.c and lib/kstrtox.c */
> +
> +static int __init prom_strcmp(const char *cs, const char *ct)
> +{
> +	unsigned char c1, c2;
> +
> +	while (1) {
> +		c1 = *cs++;
> +		c2 = *ct++;
> +		if (c1 != c2)
> +			return c1 < c2 ? -1 : 1;
> +		if (!c1)
> +			break;
> +	}
> +	return 0;
> +}
> +
> +static char __init *prom_strcpy(char *dest, const char *src)
> +{
> +	char *tmp = dest;
> +
> +	while ((*dest++ = *src++) != '\0')
> +		/* nothing */;
> +	return tmp;
> +}
> +
> +static int __init prom_strncmp(const char *cs, const char *ct, size_t count)
> +{
> +	unsigned char c1, c2;
> +
> +	while (count) {
> +		c1 = *cs++;
> +		c2 = *ct++;
> +		if (c1 != c2)
> +			return c1 < c2 ? -1 : 1;
> +		if (!c1)
> +			break;
> +		count--;
> +	}
> +	return 0;
> +}
> +
> +static size_t __init prom_strlen(const char *s)
> +{
> +	const char *sc;
> +
> +	for (sc = s; *sc != '\0'; ++sc)
> +		/* nothing */;
> +	return sc - s;
> +}
> +
> +static int __init prom_memcmp(const void *cs, const void *ct, size_t count)
> +{
> +	const unsigned char *su1, *su2;
> +	int res = 0;
> +
> +	for (su1 = cs, su2 = ct; 0 < count; ++su1, ++su2, count--)
> +		if ((res = *su1 - *su2) != 0)
> +			break;
> +	return res;
> +}
> +
> +static char __init *prom_strstr(const char *s1, const char *s2)
> +{
> +	size_t l1, l2;
> +
> +	l2 = prom_strlen(s2);
> +	if (!l2)
> +		return (char *)s1;
> +	l1 = prom_strlen(s1);
> +	while (l1 >= l2) {
> +		l1--;
> +		if (!prom_memcmp(s1, s2, l2))
> +			return (char *)s1;
> +		s1++;
> +	}
> +	return NULL;
> +}
> +
> +static size_t __init prom_strlcpy(char *dest, const char *src, size_t size)
> +{
> +	size_t ret = prom_strlen(src);
> +
> +	if (size) {
> +		size_t len = (ret >= size) ? size - 1 : ret;
> +		memcpy(dest, src, len);
> +		dest[len] = '\0';
> +	}
> +	return ret;
> +}
> +
> +#ifdef CONFIG_PPC_PSERIES
> +static int __init prom_strtobool(const char *s, bool *res)
> +{
> +	if (!s)
> +		return -EINVAL;
> +
> +	switch (s[0]) {
> +	case 'y':
> +	case 'Y':
> +	case '1':
> +		*res = true;
> +		return 0;
> +	case 'n':
> +	case 'N':
> +	case '0':
> +		*res = false;
> +		return 0;
> +	case 'o':
> +	case 'O':
> +		switch (s[1]) {
> +		case 'n':
> +		case 'N':
> +			*res = true;
> +			return 0;
> +		case 'f':
> +		case 'F':
> +			*res = false;
> +			return 0;
> +		default:
> +			break;
> +		}
> +	default:
> +		break;
> +	}
> +
> +	return -EINVAL;
> +}
> +#endif
>  
>  /* This is the one and *ONLY* place where we actually call open
>   * firmware.
> @@ -555,7 +684,7 @@ static int __init prom_setprop(phandle node, const char *nodename,
>  	add_string(&p, tohex((u32)(unsigned long) value));
>  	add_string(&p, tohex(valuelen));
>  	add_string(&p, tohex(ADDR(pname)));
> -	add_string(&p, tohex(strlen(pname)));
> +	add_string(&p, tohex(prom_strlen(pname)));
>  	add_string(&p, "property");
>  	*p = 0;
>  	return call_prom("interpret", 1, 1, (u32)(unsigned long) cmd);
> @@ -638,23 +767,23 @@ static void __init early_cmdline_parse(void)
>  	if ((long)prom.chosen > 0)
>  		l = prom_getprop(prom.chosen, "bootargs", p, COMMAND_LINE_SIZE-1);
>  	if (IS_ENABLED(CONFIG_CMDLINE_BOOL) && (l <= 0 || p[0] == '\0')) /* dbl check */
> -		strlcpy(prom_cmd_line, CONFIG_CMDLINE, sizeof(prom_cmd_line));
> +		prom_strlcpy(prom_cmd_line, CONFIG_CMDLINE, sizeof(prom_cmd_line));
>  	prom_printf("command line: %s\n", prom_cmd_line);
>  
>  #ifdef CONFIG_PPC64
> -	opt = strstr(prom_cmd_line, "iommu=");
> +	opt = prom_strstr(prom_cmd_line, "iommu=");
>  	if (opt) {
>  		prom_printf("iommu opt is: %s\n", opt);
>  		opt += 6;
>  		while (*opt && *opt == ' ')
>  			opt++;
> -		if (!strncmp(opt, "off", 3))
> +		if (!prom_strncmp(opt, "off", 3))
>  			prom_iommu_off = 1;
> -		else if (!strncmp(opt, "force", 5))
> +		else if (!prom_strncmp(opt, "force", 5))
>  			prom_iommu_force_on = 1;
>  	}
>  #endif
> -	opt = strstr(prom_cmd_line, "mem=");
> +	opt = prom_strstr(prom_cmd_line, "mem=");
>  	if (opt) {
>  		opt += 4;
>  		prom_memory_limit = prom_memparse(opt, (const char **)&opt);
> @@ -666,13 +795,13 @@ static void __init early_cmdline_parse(void)
>  
>  #ifdef CONFIG_PPC_PSERIES
>  	prom_radix_disable = !IS_ENABLED(CONFIG_PPC_RADIX_MMU_DEFAULT);
> -	opt = strstr(prom_cmd_line, "disable_radix");
> +	opt = prom_strstr(prom_cmd_line, "disable_radix");
>  	if (opt) {
>  		opt += 13;
>  		if (*opt && *opt == '=') {
>  			bool val;
>  
> -			if (kstrtobool(++opt, &val))
> +			if (prom_strtobool(++opt, &val))
>  				prom_radix_disable = false;
>  			else
>  				prom_radix_disable = val;
> @@ -1025,7 +1154,7 @@ static int __init prom_count_smt_threads(void)
>  		type[0] = 0;
>  		prom_getprop(node, "device_type", type, sizeof(type));
>  
> -		if (strcmp(type, "cpu"))
> +		if (prom_strcmp(type, "cpu"))
>  			continue;
>  		/*
>  		 * There is an entry for each smt thread, each entry being
> @@ -1472,7 +1601,7 @@ static void __init prom_init_mem(void)
>  			 */
>  			prom_getprop(node, "name", type, sizeof(type));
>  		}
> -		if (strcmp(type, "memory"))
> +		if (prom_strcmp(type, "memory"))
>  			continue;
>  
>  		plen = prom_getprop(node, "reg", regbuf, sizeof(regbuf));
> @@ -1753,19 +1882,19 @@ static void __init prom_initialize_tce_table(void)
>  		prom_getprop(node, "device_type", type, sizeof(type));
>  		prom_getprop(node, "model", model, sizeof(model));
>  
> -		if ((type[0] == 0) || (strstr(type, "pci") == NULL))
> +		if ((type[0] == 0) || (prom_strstr(type, "pci") == NULL))
>  			continue;
>  
>  		/* Keep the old logic intact to avoid regression. */
>  		if (compatible[0] != 0) {
> -			if ((strstr(compatible, "python") == NULL) &&
> -			    (strstr(compatible, "Speedwagon") == NULL) &&
> -			    (strstr(compatible, "Winnipeg") == NULL))
> +			if ((prom_strstr(compatible, "python") == NULL) &&
> +			    (prom_strstr(compatible, "Speedwagon") == NULL) &&
> +			    (prom_strstr(compatible, "Winnipeg") == NULL))
>  				continue;
>  		} else if (model[0] != 0) {
> -			if ((strstr(model, "ython") == NULL) &&
> -			    (strstr(model, "peedwagon") == NULL) &&
> -			    (strstr(model, "innipeg") == NULL))
> +			if ((prom_strstr(model, "ython") == NULL) &&
> +			    (prom_strstr(model, "peedwagon") == NULL) &&
> +			    (prom_strstr(model, "innipeg") == NULL))
>  				continue;
>  		}
>  
> @@ -1914,12 +2043,12 @@ static void __init prom_hold_cpus(void)
>  
>  		type[0] = 0;
>  		prom_getprop(node, "device_type", type, sizeof(type));
> -		if (strcmp(type, "cpu") != 0)
> +		if (prom_strcmp(type, "cpu") != 0)
>  			continue;
>  
>  		/* Skip non-configured cpus. */
>  		if (prom_getprop(node, "status", type, sizeof(type)) > 0)
> -			if (strcmp(type, "okay") != 0)
> +			if (prom_strcmp(type, "okay") != 0)
>  				continue;
>  
>  		reg = cpu_to_be32(-1); /* make sparse happy */
> @@ -1995,9 +2124,9 @@ static void __init prom_find_mmu(void)
>  		return;
>  	version[sizeof(version) - 1] = 0;
>  	/* XXX might need to add other versions here */
> -	if (strcmp(version, "Open Firmware, 1.0.5") == 0)
> +	if (prom_strcmp(version, "Open Firmware, 1.0.5") == 0)
>  		of_workarounds = OF_WA_CLAIM;
> -	else if (strncmp(version, "FirmWorks,3.", 12) == 0) {
> +	else if (prom_strncmp(version, "FirmWorks,3.", 12) == 0) {
>  		of_workarounds = OF_WA_CLAIM | OF_WA_LONGTRAIL;
>  		call_prom("interpret", 1, 1, "dev /memory 0 to allow-reclaim");
>  	} else
> @@ -2030,7 +2159,7 @@ static void __init prom_init_stdout(void)
>  	call_prom("instance-to-path", 3, 1, prom.stdout, path, 255);
>  	prom_printf("OF stdout device is: %s\n", of_stdout_device);
>  	prom_setprop(prom.chosen, "/chosen", "linux,stdout-path",
> -		     path, strlen(path) + 1);
> +		     path, prom_strlen(path) + 1);
>  
>  	/* instance-to-package fails on PA-Semi */
>  	stdout_node = call_prom("instance-to-package", 1, 1, prom.stdout);
> @@ -2040,7 +2169,7 @@ static void __init prom_init_stdout(void)
>  		/* If it's a display, note it */
>  		memset(type, 0, sizeof(type));
>  		prom_getprop(stdout_node, "device_type", type, sizeof(type));
> -		if (strcmp(type, "display") == 0)
> +		if (prom_strcmp(type, "display") == 0)
>  			prom_setprop(stdout_node, path, "linux,boot-display", NULL, 0);
>  	}
>  }
> @@ -2061,19 +2190,19 @@ static int __init prom_find_machine_type(void)
>  		compat[len] = 0;
>  		while (i < len) {
>  			char *p = &compat[i];
> -			int sl = strlen(p);
> +			int sl = prom_strlen(p);
>  			if (sl == 0)
>  				break;
> -			if (strstr(p, "Power Macintosh") ||
> -			    strstr(p, "MacRISC"))
> +			if (prom_strstr(p, "Power Macintosh") ||
> +			    prom_strstr(p, "MacRISC"))
>  				return PLATFORM_POWERMAC;
>  #ifdef CONFIG_PPC64
>  			/* We must make sure we don't detect the IBM Cell
>  			 * blades as pSeries due to some firmware issues,
>  			 * so we do it here.
>  			 */
> -			if (strstr(p, "IBM,CBEA") ||
> -			    strstr(p, "IBM,CPBW-1.0"))
> +			if (prom_strstr(p, "IBM,CBEA") ||
> +			    prom_strstr(p, "IBM,CPBW-1.0"))
>  				return PLATFORM_GENERIC;
>  #endif /* CONFIG_PPC64 */
>  			i += sl + 1;
> @@ -2090,7 +2219,7 @@ static int __init prom_find_machine_type(void)
>  			   compat, sizeof(compat)-1);
>  	if (len <= 0)
>  		return PLATFORM_GENERIC;
> -	if (strcmp(compat, "chrp"))
> +	if (prom_strcmp(compat, "chrp"))
>  		return PLATFORM_GENERIC;
>  
>  	/* Default to pSeries. We need to know if we are running LPAR */
> @@ -2152,7 +2281,7 @@ static void __init prom_check_displays(void)
>  	for (node = 0; prom_next_node(&node); ) {
>  		memset(type, 0, sizeof(type));
>  		prom_getprop(node, "device_type", type, sizeof(type));
> -		if (strcmp(type, "display") != 0)
> +		if (prom_strcmp(type, "display") != 0)
>  			continue;
>  
>  		/* It seems OF doesn't null-terminate the path :-( */
> @@ -2256,9 +2385,9 @@ static unsigned long __init dt_find_string(char *str)
>  	s = os = (char *)dt_string_start;
>  	s += 4;
>  	while (s <  (char *)dt_string_end) {
> -		if (strcmp(s, str) == 0)
> +		if (prom_strcmp(s, str) == 0)
>  			return s - os;
> -		s += strlen(s) + 1;
> +		s += prom_strlen(s) + 1;
>  	}
>  	return 0;
>  }
> @@ -2291,7 +2420,7 @@ static void __init scan_dt_build_strings(phandle node,
>  		}
>  
>   		/* skip "name" */
> - 		if (strcmp(namep, "name") == 0) {
> +		if (prom_strcmp(namep, "name") == 0) {
>   			*mem_start = (unsigned long)namep;
>   			prev_name = "name";
>   			continue;
> @@ -2303,7 +2432,7 @@ static void __init scan_dt_build_strings(phandle node,
>  			namep = sstart + soff;
>  		} else {
>  			/* Trim off some if we can */
> -			*mem_start = (unsigned long)namep + strlen(namep) + 1;
> +			*mem_start = (unsigned long)namep + prom_strlen(namep) + 1;
>  			dt_string_end = *mem_start;
>  		}
>  		prev_name = namep;
> @@ -2372,7 +2501,7 @@ static void __init scan_dt_build_struct(phandle node, unsigned long *mem_start,
>  			break;
>  
>   		/* skip "name" */
> - 		if (strcmp(pname, "name") == 0) {
> +		if (prom_strcmp(pname, "name") == 0) {
>   			prev_name = "name";
>   			continue;
>   		}
> @@ -2403,7 +2532,7 @@ static void __init scan_dt_build_struct(phandle node, unsigned long *mem_start,
>  		call_prom("getprop", 4, 1, node, pname, valp, l);
>  		*mem_start = _ALIGN(*mem_start, 4);
>  
> -		if (!strcmp(pname, "phandle"))
> +		if (!prom_strcmp(pname, "phandle"))
>  			has_phandle = 1;
>  	}
>  
> @@ -2473,8 +2602,8 @@ static void __init flatten_device_tree(void)
>  
>  	/* Add "phandle" in there, we'll need it */
>  	namep = make_room(&mem_start, &mem_end, 16, 1);
> -	strcpy(namep, "phandle");
> -	mem_start = (unsigned long)namep + strlen(namep) + 1;
> +	prom_strcpy(namep, "phandle");
> +	mem_start = (unsigned long)namep + prom_strlen(namep) + 1;
>  
>  	/* Build string array */
>  	prom_printf("Building dt strings...\n"); 
> @@ -2796,7 +2925,7 @@ static void __init fixup_device_tree_efika(void)
>  	rv = prom_getprop(node, "model", prop, sizeof(prop));
>  	if (rv == PROM_ERROR)
>  		return;
> -	if (strcmp(prop, "EFIKA5K2"))
> +	if (prom_strcmp(prop, "EFIKA5K2"))
>  		return;
>  
>  	prom_printf("Applying EFIKA device tree fixups\n");
> @@ -2804,13 +2933,13 @@ static void __init fixup_device_tree_efika(void)
>  	/* Claiming to be 'chrp' is death */
>  	node = call_prom("finddevice", 1, 1, ADDR("/"));
>  	rv = prom_getprop(node, "device_type", prop, sizeof(prop));
> -	if (rv != PROM_ERROR && (strcmp(prop, "chrp") == 0))
> +	if (rv != PROM_ERROR && (prom_strcmp(prop, "chrp") == 0))
>  		prom_setprop(node, "/", "device_type", "efika", sizeof("efika"));
>  
>  	/* CODEGEN,description is exposed in /proc/cpuinfo so
>  	   fix that too */
>  	rv = prom_getprop(node, "CODEGEN,description", prop, sizeof(prop));
> -	if (rv != PROM_ERROR && (strstr(prop, "CHRP")))
> +	if (rv != PROM_ERROR && (prom_strstr(prop, "CHRP")))
>  		prom_setprop(node, "/", "CODEGEN,description",
>  			     "Efika 5200B PowerPC System",
>  			     sizeof("Efika 5200B PowerPC System"));
> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
> index 181fd10008ef..4cac45cb5de5 100644
> --- a/arch/powerpc/kernel/prom_init_check.sh
> +++ b/arch/powerpc/kernel/prom_init_check.sh
> @@ -27,7 +27,7 @@ fi
>  WHITELIST="add_reloc_offset __bss_start __bss_stop copy_and_flush
>  _end enter_prom $MEM_FUNCS reloc_offset __secondary_hold
>  __secondary_hold_acknowledge __secondary_hold_spinloop __start
> -strcmp strcpy strlcpy strlen strncmp strstr kstrtobool logo_linux_clut224
> +logo_linux_clut224
>  reloc_got2 kernstart_addr memstart_addr linux_banner _stext
>  __prom_init_toc_start __prom_init_toc_end btext_setup_display TOC."
>  
> -- 
> 2.13.3

