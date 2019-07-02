Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34DF9C06515
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D56B42183F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:20:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D56B42183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7476B0003; Tue,  2 Jul 2019 10:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 560008E0003; Tue,  2 Jul 2019 10:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9F08E0001; Tue,  2 Jul 2019 10:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D66D06B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:20:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so19572524eda.9
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:20:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N1bQKvAa1B/1FWkAFHigi6z0OOVNRyWnM/hOn3I6fCU=;
        b=Z6BJpu5aWVl8L6TlHmg5WTfyry1pkgtbwnTWP9CKLzApQDNrWDUnGL4OBpHGCLUr5w
         3aQvyVGdrYfciiwVwklpbPNiYiijm5SDJhtuxtol0Y4XseO0k5dRDurmHFKgAN7zFS/p
         M95VzhvG2s1DRZ2IAIOdVrv29sGftLNmyBNqoaojAQNl9oN5GWd6TgoCKnqzIddSO3PL
         iX2Ks+iqsN1iX28bNxVsJP0mV7rOQNXGVmd95bzuCGeL2Pg0lbylB54N3fy4ABEx/Fiu
         hJ+F0+i8lXTllXDUB4MXso1Z8VBiN9e+sqqL9hohEUnCcQfshJPTX26zioWFo4oH94JC
         izlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWWWzZZjGWUh0sEONs/Xn+acxhmagNEsJ65veJO1tU5rvAr0o8q
	NvqRdzybjojjR5tUMfRIrfPnn/DAdVG3JJjU+TgN+E4QkM54Q+WN2RGoqsnCBAwJCil8P5l7/2M
	ne0xWJljHBWZIHi8AYNxM6nLc0hbwL/rAa7H0wYCThcIf9XxKhgmGprotRt9VcRq+Kw==
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr36350225edy.160.1562077215276;
        Tue, 02 Jul 2019 07:20:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV/42WcYe9y34h6WrbfNCMavDbGbnNfMKBEqRP5Li8C83tp0LpUibKvfJ6x929qa+qA3ek
X-Received: by 2002:a05:6402:78c:: with SMTP id d12mr36350093edy.160.1562077213906;
        Tue, 02 Jul 2019 07:20:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562077213; cv=none;
        d=google.com; s=arc-20160816;
        b=vJIffWd4XnZniWiQ5HboY7h/knTBfKB+wVdVmZurc1DLeh1MXUbvkx9JQwzhkF+jLB
         yzOb3KK4lLoFDp2zY7tZ+AWGtXJO7YGtgT6ss1b4T+V0n1+396nZkRYKrTSHOBws/Ise
         dhy6zb6bTJ9GU5dsOOcyLEea4bC5FdIiP1PShuzpIt35TM6pR5Xg8rMVAhTar+9a8fSb
         Gu95ePB4hKQ95NiIQvqNp5ntnWDyZ0T9wRgRVkvQrrbdBymSvPV0IIvyR9P/k5mSXZKA
         CH9nOkpOGLgCqnOrmh+f7yfakAf2Uy7hzqrPI+d1laaH9SvllQ1EWnz01Zd2xUyY52Fa
         Hlsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N1bQKvAa1B/1FWkAFHigi6z0OOVNRyWnM/hOn3I6fCU=;
        b=w/GCJZYt9tiijoOX1K58JUqDkEyrq3qTtNybQhVT5WzF6LCwG7/kPW330qxPOt6tOL
         WRlbuGlAGvQbXZRHDXx5i0pieZ6W+RK4xuzdT5dCePRF7cSf7u/q0uO7ObNYABob5xjc
         3ztj/nrs9NoyBR0Gp37kcNa3ZhT2kS3Vtz3qfQnLxl1m85s10m1djhAaKku2YF+gub+V
         +MdBbWHxnNr/E3BxbZKEzTDNoB9Eu4fk4d2bC3HxyeCUPXXbqSZ53beVkKTmgMjeV9zJ
         1ycQX/Wbgrq7KvDYhIxtTcy9WMrsUbOjwBXIV2NyAVZ+42mRLdoVCfn0i6SPLXu2rog+
         pKzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y9si11143084edb.262.2019.07.02.07.20.13
        for <linux-mm@kvack.org>;
        Tue, 02 Jul 2019 07:20:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B0A2128;
	Tue,  2 Jul 2019 07:20:12 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 07E723F703;
	Tue,  2 Jul 2019 07:20:08 -0700 (PDT)
Date: Tue, 2 Jul 2019 15:20:06 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [RFC PATCH] binfmt_elf: Extract .note.gnu.property from an ELF
 file
Message-ID: <20190702141959.GP2790@e103592.cambridge.arm.com>
References: <20190628172203.797-1-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628172203.797-1-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:22:03AM -0700, Yu-cheng Yu wrote:
> This patch was part of the Intel Control-flow Enforcement (CET) series at:
> 
>     https://lkml.org/lkml/2019/6/6/1014.
> 
> In the discussion, we decided to look at only an ELF header's
> PT_GNU_PROPERTY, which is a shortcut pointing to the file's
> .note.gnu.property.
> 
> The Linux gABI extension draft is here:
> 
>     https://github.com/hjl-tools/linux-abi/wiki/linux-abi-draft.pdf.
> 
> A few existing CET-enabled binary files were built without
> PT_GNU_PROPERTY; but those files' .note.gnu.property are checked by
> ld-linux, not Linux.  The compatibility impact from this change is
> therefore managable.

That's convenient :)

> An ELF file's .note.gnu.property indicates features the executable file
> can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> 
> With this patch, if an arch needs to setup features from ELF properties,
> it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and specific
> arch_parse_property() and arch_setup_property().
> 
> This work is derived from code provided by H.J. Lu <hjl.tools@gmail.com>.

Thanks for reworking this ... comments below.

> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  fs/Kconfig.binfmt        |   3 +
>  fs/Makefile              |   1 +
>  fs/binfmt_elf.c          |  20 +++
>  fs/gnu_property.c        | 279 +++++++++++++++++++++++++++++++++++++++
>  include/linux/elf.h      |  11 ++
>  include/uapi/linux/elf.h |  14 ++
>  6 files changed, 328 insertions(+)
>  create mode 100644 fs/gnu_property.c
> 
> diff --git a/fs/Kconfig.binfmt b/fs/Kconfig.binfmt
> index f87ddd1b6d72..397138ab305b 100644
> --- a/fs/Kconfig.binfmt
> +++ b/fs/Kconfig.binfmt
> @@ -36,6 +36,9 @@ config COMPAT_BINFMT_ELF
>  config ARCH_BINFMT_ELF_STATE
>  	bool
>  
> +config ARCH_USE_GNU_PROPERTY
> +	bool
> +
>  config BINFMT_ELF_FDPIC
>  	bool "Kernel support for FDPIC ELF binaries"
>  	default y if !BINFMT_ELF
> diff --git a/fs/Makefile b/fs/Makefile
> index c9aea23aba56..b69f18c14e09 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -44,6 +44,7 @@ obj-$(CONFIG_BINFMT_ELF)	+= binfmt_elf.o
>  obj-$(CONFIG_COMPAT_BINFMT_ELF)	+= compat_binfmt_elf.o
>  obj-$(CONFIG_BINFMT_ELF_FDPIC)	+= binfmt_elf_fdpic.o
>  obj-$(CONFIG_BINFMT_FLAT)	+= binfmt_flat.o
> +obj-$(CONFIG_ARCH_USE_GNU_PROPERTY) += gnu_property.o
>  
>  obj-$(CONFIG_FS_MBCACHE)	+= mbcache.o
>  obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 8264b468f283..cbc6d68f4a18 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -852,6 +852,21 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  			}
>  	}
>  
> +	if (interpreter) {
> +		retval = arch_parse_property(&loc->interp_elf_ex,
> +					     interp_elf_phdata,
> +					     interpreter, true,
> +					     &arch_state);
> +	} else {
> +		retval = arch_parse_property(&loc->elf_ex,
> +					     elf_phdata,
> +					     bprm->file, false,
> +					     &arch_state);
> +	}
> +
> +	if (retval)
> +		goto out_free_dentry;
> +
>  	/*
>  	 * Allow arch code to reject the ELF at this point, whilst it's
>  	 * still possible to return an error to the code that invoked
> @@ -1080,6 +1095,11 @@ static int load_elf_binary(struct linux_binprm *bprm)
>  		goto out_free_dentry;
>  	}
>  
> +	retval = arch_setup_property(&arch_state);
> +
> +	if (retval < 0)
> +		goto out_free_dentry;
> +
>  	if (interpreter) {
>  		unsigned long interp_map_addr = 0;
>  
> diff --git a/fs/gnu_property.c b/fs/gnu_property.c
> new file mode 100644
> index 000000000000..37cd503a0c48
> --- /dev/null
> +++ b/fs/gnu_property.c
> @@ -0,0 +1,279 @@
> +/* SPDX-License-Identifier: GPL-2.0-only */
> +/*
> + * Extract an ELF file's .note.gnu.property.
> + *
> + * The path from the ELF header to the note section is the following:
> + * elfhdr->elf_phdr->elf_note->property[].
> + */
> +
> +#include <uapi/linux/elf-em.h>
> +#include <linux/processor.h>
> +#include <linux/binfmts.h>
> +#include <linux/elf.h>
> +#include <linux/slab.h>
> +#include <linux/fs.h>
> +#include <linux/uaccess.h>
> +#include <linux/string.h>
> +#include <linux/compat.h>
> +
> +/*
> + * The .note.gnu.property layout:
> + *
> + *	struct elf_note {
> + *		u32 n_namesz; --> sizeof(n_name[]); always (4)
> + *		u32 n_ndescsz;--> sizeof(property[])
> + *		u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0 (5)
> + *	};
> + *	char n_name[4]; --> always 'GNU\0'
> + *
> + *	struct {
> + *		struct gnu_property {
> + *			u32 pr_type;
> + *			u32 pr_datasz;
> + *		};
> + *		u8 pr_data[pr_datasz];
> + *	}[];
> + */
> +
> +typedef bool (test_item_fn)(void *buf, u32 *arg, u32 type);
> +typedef void *(next_item_fn)(void *buf, u32 *arg, u32 type);
> +
> +static bool test_property(void *buf, u32 *max_type, u32 pr_type)
> +{
> +	struct gnu_property *pr = buf;
> +
> +	/*
> +	 * Property types must be in ascending order.
> +	 * Keep track of the max when testing each.
> +	 */
> +	if (pr->pr_type > *max_type)
> +		*max_type = pr->pr_type;
> +
> +	return (pr->pr_type == pr_type);
> +}
> +
> +static void *next_property(void *buf, u32 *max_type, u32 pr_type)
> +{
> +	struct gnu_property *pr = buf;
> +
> +	if ((buf + sizeof(*pr) + pr->pr_datasz < buf) ||
> +	    (pr->pr_type > pr_type) ||
> +	    (pr->pr_type > *max_type))
> +		return NULL;
> +	else
> +		return (buf + sizeof(*pr) + pr->pr_datasz);
> +}
> +
> +/*
> + * Scan 'buf' for a pattern; return true if found.
> + * *pos is the distance from the beginning of buf to where
> + * the searched item or the next item is located.
> + */
> +static int scan(u8 *buf, u32 buf_size, int item_size, test_item_fn test_item,
> +		next_item_fn next_item, u32 *arg, u32 type, u32 *pos)
> +{
> +	int found = 0;
> +	u8 *p, *max;
> +
> +	max = buf + buf_size;
> +	if (max < buf)
> +		return 0;
> +
> +	p = buf;
> +
> +	while ((p + item_size < max) && (p + item_size > buf)) {
> +		if (test_item(p, arg, type)) {
> +			found = 1;
> +			break;
> +		}
> +
> +		p = next_item(p, arg, type);
> +	}
> +
> +	*pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
> +	return found;
> +}
> +
> +/*
> + * Search an NT_GNU_PROPERTY_TYPE_0 for the property of 'pr_type'.
> + */
> +static int find_property(u32 pr_type, u32 *property, struct file *file,
> +			 loff_t file_offset, unsigned long desc_size)
> +{
> +	u8 *buf;
> +	int buf_size;
> +
> +	u32 buf_pos;
> +	unsigned long read_size;
> +	unsigned long done;
> +	int found = 0;
> +	int ret = 0;
> +	u32 last_pr = 0;
> +
> +	*property = 0;
> +	buf_pos = 0;
> +
> +	buf_size = (desc_size > PAGE_SIZE) ? PAGE_SIZE : desc_size;
> +	buf = kmalloc(buf_size, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	for (done = 0; done < desc_size; done += buf_pos) {
> +		read_size = desc_size - done;
> +		if (read_size > buf_size)
> +			read_size = buf_size;
> +
> +		ret = kernel_read(file, buf, read_size, &file_offset);

This can be simpler if we just read the whole PT_GNU_PROPERTY segment
before hand.

We should set some sanity limit on the size we accept, but I don't think
it's realistically going to be very big.

> +
> +		if (ret != read_size)
> +			return (ret < 0) ? ret : -EIO;
> +
> +		ret = 0;
> +		found = scan(buf, read_size, sizeof(struct gnu_property),
> +			     test_property, next_property,
> +			     &last_pr, pr_type, &buf_pos);
> +
> +		if ((!buf_pos) || found)
> +			break;
> +
> +		file_offset += buf_pos - read_size;
> +	}
> +
> +	if (found) {
> +		struct gnu_property *pr =
> +			(struct gnu_property *)(buf + buf_pos);
> +
> +		if (pr->pr_datasz == 4) {
> +			u32 *max =  (u32 *)(buf + read_size);
> +			u32 *data = (u32 *)((u8 *)pr + sizeof(*pr));
> +
> +			if (data + 1 <= max) {
> +				*property = *data;
> +			} else {
> +				file_offset += buf_pos - read_size;
> +				file_offset += sizeof(*pr);
> +				ret = kernel_read(file, property, 4,
> +						  &file_offset);
> +			}
> +		}
> +	}
> +
> +	kfree(buf);
> +	return ret;
> +}
> +
> +/*
> + * Look at an ELF file's PT_GNU_PROPERTY for the property of pr_type.
> + *
> + * Input:
> + *	file: the file to search;
> + *	phdr: the file's elf header;
> + *	phnum: number of entries in phdr;
> + *	pr_type: the property type.
> + *
> + * Output:
> + *	The property found.
> + *
> + * Return:
> + *	Zero or error.
> + */
> +
> +static int scan_segments_64(struct file *file, struct elf64_phdr *phdr,
> +			    int phnum, u32 pr_type, u32 *property)
> +{
> +	int i, err;
> +
> +	err = 0;
> +
> +	for (i = 0; i < phnum; i++, phdr++) {
> +		if (phdr->p_align != 8)
> +			continue;
> +
> +		if (phdr->p_type == PT_GNU_PROPERTY) {
> +			struct elf64_note n;
> +			loff_t pos;
> +
> +			/* read note header */
> +			pos = phdr->p_offset;
> +			err = kernel_read(file, &n, sizeof(n), &pos);
> +			if (err < sizeof(n))
> +				return -EIO;

Should we check n_type and n_name?

Maybe we don't need to bother if we trust the tools not to put garbage
on PT_GNU_PROPERTY.  I'm a little concerned that hjl's spec is pretty
vague on what the PT_GNU_PROPERTY segment should contain (even it it's
"obvious").

> +
> +			/* find note payload offset */
> +			pos = phdr->p_offset + round_up(sizeof(n) + n.n_namesz,
> +							phdr->p_align);
> +
> +			err = find_property(pr_type, property, file,
> +					    pos, n.n_descsz);
> +			break;
> +		}
> +	}
> +
> +	return err;
> +}
> +
> +static int scan_segments_32(struct file *file, struct elf32_phdr *phdr,
> +			    int phnum, u32 pr_type, u32 *property)
> +{
> +	int i, err;
> +
> +	err = 0;
> +
> +	for (i = 0; i < phnum; i++, phdr++) {
> +		if (phdr->p_align != 4)
> +			continue;
> +
> +		if (phdr->p_type == PT_GNU_PROPERTY) {

I wonder whether we should stick a printk_once here, along the lines of
"malformed PT_GNU_PROPERTY note ignored, go fix your toolchain".

Otherwise, maybe we don't need to bother to check this at all: if the
toolchain generates bad binaries, it's arguably not our problem?

(For example, we don't even bother to check that e_ident[EI_DATA]
matches the host endianness..., and we don't look at e_ident[EI_VERSION]
etc.)

		if (phdr->p_type != PT_GNU_PROPERTY)
			continue;

		if (phdr->p_align != 4) {
			/* complaining printk */
			break;
		}

		/* handle PT_GNU_PROPERTY */

> +			struct elf32_note n;
> +			loff_t pos;
> +
> +			/* read note header */
> +			pos = phdr->p_offset;
> +			err = kernel_read(file, &n, sizeof(n), &pos);

Would it be simpler just to load the whole segment using phdr->p_memsz?
This would allow us to do just a single kernel_read()?

> +			if (err < sizeof(n))
> +				return -EIO;
> +
> +			/* find note payload offset */
> +			pos = phdr->p_offset + round_up(sizeof(n) + n.n_namesz,
> +							phdr->p_align);
> +
> +			err = find_property(pr_type, property, file,
> +					    pos, n.n_descsz);
> +			break;
> +		}
> +	}
> +
> +	return err;
> +}

These two functions look the same except for trivial details.

Can we pass in a pointer to the ELF header, and a void * or union
pointer for the phdrs?  We already do those tricks for calling
get_gnu_property() anyway.

> +
> +int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
> +		     u32 pr_type, u32 *property)

Do we have to call this every time we want to fetch a property?

This will be costly if there are several properties we want to
look at.  I can also imagine that some properties will be generic
while others are arch-specific.

So, if the arch or generic code wants properties, we call this
from the generic code, and call out to arch and generic hooks to
handle any properties found.  That way we would only need to do
this scan once.

> +{
> +	struct elf64_hdr *ehdr64 = ehdr_p;
> +	int err = 0;
> +
> +	*property = 0;
> +
> +	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> +		struct elf64_phdr *phdr64 = phdr_p;
> +
> +		err = scan_segments_64(f, phdr64, ehdr64->e_phnum,
> +				       pr_type, property);
> +		if (err < 0)
> +			goto out;
> +	} else {
> +		struct elf32_hdr *ehdr32 = ehdr_p;
> +
> +		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
> +			struct elf32_phdr *phdr32 = phdr_p;
> +
> +			err = scan_segments_32(f, phdr32, ehdr32->e_phnum,
> +					       pr_type, property);
> +			if (err < 0)
> +				goto out;
> +		}
> +	}

We still do nothing and return 0 if e_ident->[EI_CLASS] is neither
ELFCLASS32 or ELFCLASS64, which seems a bit odd.

If we think this should never happen, it might be worth sticking a
WARN() in here and returning an error just in case.

> +
> +out:
> +	return err;
> +}
> diff --git a/include/linux/elf.h b/include/linux/elf.h
> index e3649b3e970e..c86cbfd17382 100644
> --- a/include/linux/elf.h
> +++ b/include/linux/elf.h
> @@ -56,4 +56,15 @@ static inline int elf_coredump_extra_notes_write(struct coredump_params *cprm) {
>  extern int elf_coredump_extra_notes_size(void);
>  extern int elf_coredump_extra_notes_write(struct coredump_params *cprm);
>  #endif
> +
> +#ifdef CONFIG_ARCH_USE_GNU_PROPERTY
> +extern int arch_parse_property(void *ehdr, void *phdr, struct file *f,
> +			       bool inter, struct arch_elf_state *state);
> +extern int arch_setup_property(struct arch_elf_state *state);
> +extern int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
> +			    u32 pr_type, u32 *feature);
> +#else
> +#define arch_parse_property(ehdr, phdr, file, inter, state) (0)
> +#define arch_setup_property(state) (0)

Can we make these fallbacks into static inlines, so that we still get
argument type checking?

> +#endif
>  #endif /* _LINUX_ELF_H */
> diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
> index 34c02e4290fe..530ce08467c2 100644
> --- a/include/uapi/linux/elf.h
> +++ b/include/uapi/linux/elf.h
> @@ -36,6 +36,7 @@ typedef __s64	Elf64_Sxword;
>  #define PT_LOPROC  0x70000000
>  #define PT_HIPROC  0x7fffffff
>  #define PT_GNU_EH_FRAME		0x6474e550
> +#define PT_GNU_PROPERTY		0x6474e553
>  
>  #define PT_GNU_STACK	(PT_LOOS + 0x474e551)
>  
> @@ -443,4 +444,17 @@ typedef struct elf64_note {
>    Elf64_Word n_type;	/* Content type */
>  } Elf64_Nhdr;
>  
> +/* NT_GNU_PROPERTY_TYPE_0 header */
> +struct gnu_property {
> +  __u32 pr_type;
> +  __u32 pr_datasz;

Would it make sense to have

	__u8 pr_data[];

here?

We should also be using the Elf types here for pr_type and pr_datasz.

Maybe we can follow hjl's lead on the definition of the type...

In linux-abi-draft.pdf, we already have

	typedef struct {
		Elf_Word pr_type;
		Elf_Word pr_datasz;
		unsigned char pr_data[PR_DATASZ];
		unsigned char pr_padding[PR_PADDING];
	} ElF_Prop;

This doesn't work as a generic definition due to the variable-sized
arrays, but we can omit pr_padding.  For Linux purposes, __u8 is
probably preferable to unsigned char for pd_data, which we can leave as
a flexible array member.

I see no reason not to introduce

typedef __u32 Elf_Word;

somewhere so that we don't have to pointlessly special-case Elf_Prop for
the 32- and 64-bit cases.

> +};
> +
> +/* .note.gnu.property types */
> +#define GNU_PROPERTY_X86_FEATURE_1_AND		0xc0000002
> +
> +/* Bits of GNU_PROPERTY_X86_FEATURE_1_AND */
> +#define GNU_PROPERTY_X86_FEATURE_1_IBT		0x00000001
> +#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	0x00000002
> +

[...]

Cheers
---Dave

