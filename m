Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0073EC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99E7E20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:49:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SSKFoyjU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99E7E20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B41F6B0003; Mon,  1 Jul 2019 15:49:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0658F8E0003; Mon,  1 Jul 2019 15:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47588E0002; Mon,  1 Jul 2019 15:49:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f80.google.com (mail-ot1-f80.google.com [209.85.210.80])
	by kanga.kvack.org (Postfix) with ESMTP id BA5C26B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 15:49:57 -0400 (EDT)
Received: by mail-ot1-f80.google.com with SMTP id w5so5450114otg.0
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 12:49:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=S054NJSICxH2WVYMj2QZmBzpirBW9pu17gcUOC2JL3E=;
        b=Rrg/Jvdee/XnvVDzuZmPyGNT8qQB6WG5c0z7AwT8Tu5M4XuWitrc99rKtTiHYyX+bI
         bYO4xinrXb2rZxHbbBdP8Mdg10GC0K/utUaa4Mwn39oeYrG4MNkKrqcCpZJwX2wEM4oi
         WhFk+Ck9Qq/GlLqlD+SNrrV2y4UdvkXvDYwuKzX9rIWoNNyNzxya/55UG52k6ybDkEg3
         nPrKB8SCqPen26gaMDaj/X/qUrjWeje235qgKAN707OKEY8RWIkySBdP8xwjPk8Z3dYs
         rMygV7a5xedm/jiGIB7LeS7luBAVcLjAA/nyiPXsF0m4LILZ+sLT4QIuqhOj6qFIuKXr
         uXjQ==
X-Gm-Message-State: APjAAAU7IIthgsWZvVpmwwwWw3FPhiN5r9M/oOYh1JBsvBLDog6N40CF
	tb+CrkFYD2Qo6wxmtg6e8m+DII3Iu62Vf07cFNJMCS/g07JsrUW739pl8ZtDiQpJCyOfKOZh8q+
	N4UEJtHIAopG7kecsGe2+U2W/Mt7QmVx4R16nD/3sHaAxZSBF/ezIH+C9ojKy5tvSDg==
X-Received: by 2002:aca:ec82:: with SMTP id k124mr582115oih.73.1562010597332;
        Mon, 01 Jul 2019 12:49:57 -0700 (PDT)
X-Received: by 2002:aca:ec82:: with SMTP id k124mr582088oih.73.1562010596507;
        Mon, 01 Jul 2019 12:49:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562010596; cv=none;
        d=google.com; s=arc-20160816;
        b=e9+bSisegxKJg/mIPswUpo4+c5BlL4Adht4G02CSv6PuPjwBi7rZ9Ua1PW1vlH2ta3
         rZESY4+3jzmVp7EL3f8wBFE8c5EelGmKoGThXGRLc0tHwiucADbzh9DQA2iWNpqm99+q
         9Be0u99/BvrZvz1NFnXyxgpj7TfP6F3XQD03O1LNL1WhwIIX72tpPiyUXMI6nHyYfaDs
         LN09xHgNEvPpfc6LkYJVKJUUT9xnz/s+dXMPZGcDP1cca1Rt2lICs83MgJOymaPs1nVL
         UXwkNNZQ5PXgNfEC63L71/Jeyq5bP+gtx35B9TgE60miPCojFjzOrml8+mBZ/neTgHAN
         QqEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=S054NJSICxH2WVYMj2QZmBzpirBW9pu17gcUOC2JL3E=;
        b=oOG7QqhhB+giLbuHd/7ay6ZAYCIrWvijY8j5CgA5ytCIrcmoH8r4qBPnoTUNnHNotC
         QzeAYyz/GnsRF6UU5g1gNnPPBwme8eCQMlNSvpSV+yqgzqxZs4bnUJtMEF8SpBtpvhF1
         hC4y/SDRziRGW8rMRt++qfMaCtzbV3rbhRfIfrSS5Pn3ZveFFuvAocXNJ0lGRxg4aiN/
         JQFMWQ8zoyqMsb0q2IJVglZa+eSqMnyE+KbBjgLg/qdxrXL0sP+aBMQ60sbvdA9vAU4n
         pbICyeG70u2WxiCtrJPISFJzDa9VDGwOory68khxlKa94q7A4vkI79r47fIJcAM/vGpH
         n6wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SSKFoyjU;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor6220692otr.23.2019.07.01.12.49.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 12:49:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SSKFoyjU;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=S054NJSICxH2WVYMj2QZmBzpirBW9pu17gcUOC2JL3E=;
        b=SSKFoyjUoA5JrydqG/b5ZPIrzADUe8JTb/5kFit1n4z3dZXZHbsIUbUPSFaLcPWQ7S
         hUBUabZSRMA5reCCV573Ol0V8x132YoSogMnumLkpdWy61Tpzi27R5UW7XFaGrt2CHbt
         GYvK7rtfRxG2jcB2lwcOddkC0j3w9Mr4irv2kAR24PfPnMkUYcOHYi6EOxzzotWiEDgD
         2WXn1zuW3+cZBTxlXS2qKWFlHb2LRa+K9/uzPdYJm8Gomn6WUXCx1YkwWM27kFleYKkP
         A0mrOlF1izN/6pNYXQruGWLEU5j2sSgma956vsk4BakMTA+ezti++nAVyhDxNyn5of5O
         HANw==
X-Google-Smtp-Source: APXvYqyxybyOMgQXZ08JkS9lEK/3daLWamrFF7d27t960AJ7WyvV4rJHucpixSzLMPbun7eVkVzASylILF21wHo9QzY=
X-Received: by 2002:a05:6830:15cd:: with SMTP id j13mr22250500otr.110.1562010594048;
 Mon, 01 Jul 2019 12:49:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190628172203.797-1-yu-cheng.yu@intel.com>
In-Reply-To: <20190628172203.797-1-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 1 Jul 2019 21:49:28 +0200
Message-ID: <CAG48ez0rHHfcRgiVZf5FP0YOzxsXigvpg6ci790cmiN6PBwkhQ@mail.gmail.com>
Subject: Re: [RFC PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: "the arch/x86 maintainers" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, 
	linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, 
	Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 7:30 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
[...]
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
>
> An ELF file's .note.gnu.property indicates features the executable file
> can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> GNU_PROPERTY_X86_FEATURE_1_SHSTK.
>
> With this patch, if an arch needs to setup features from ELF properties,
> it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and specific
> arch_parse_property() and arch_setup_property().
[...]
> +typedef bool (test_item_fn)(void *buf, u32 *arg, u32 type);
> +typedef void *(next_item_fn)(void *buf, u32 *arg, u32 type);
> +
> +static bool test_property(void *buf, u32 *max_type, u32 pr_type)
> +{
> +       struct gnu_property *pr = buf;
> +
> +       /*
> +        * Property types must be in ascending order.
> +        * Keep track of the max when testing each.
> +        */
> +       if (pr->pr_type > *max_type)
> +               *max_type = pr->pr_type;
> +
> +       return (pr->pr_type == pr_type);
> +}
> +
> +static void *next_property(void *buf, u32 *max_type, u32 pr_type)
> +{
> +       struct gnu_property *pr = buf;
> +
> +       if ((buf + sizeof(*pr) + pr->pr_datasz < buf) ||

This looks like UB to me, see below.

> +           (pr->pr_type > pr_type) ||
> +           (pr->pr_type > *max_type))
> +               return NULL;
> +       else
> +               return (buf + sizeof(*pr) + pr->pr_datasz);
> +}
> +
> +/*
> + * Scan 'buf' for a pattern; return true if found.
> + * *pos is the distance from the beginning of buf to where
> + * the searched item or the next item is located.
> + */
> +static int scan(u8 *buf, u32 buf_size, int item_size, test_item_fn test_item,
> +               next_item_fn next_item, u32 *arg, u32 type, u32 *pos)
> +{
> +       int found = 0;
> +       u8 *p, *max;
> +
> +       max = buf + buf_size;
> +       if (max < buf)
> +               return 0;

How can this ever legitimately happen? If it can't, perhaps you meant
to put a WARN_ON_ONCE() or something like that here?
Also, computing out-of-bounds pointers is UB (section 6.5.6 of C99:
"If both the pointer operand and the result point to elements of the
same array object, or one past the last element of the array object,
the evaluation shall not produce an overflow; otherwise, the behavior
is undefined."), and if the addition makes the pointer wrap, that's
certainly out of bounds; so I don't think this condition can trigger
without UB.

> +
> +       p = buf;
> +
> +       while ((p + item_size < max) && (p + item_size > buf)) {

Again, as far as I know, this is technically UB. Please rewrite this.
For example, you could do something like:

    while (max - p >= item_size) {

and then make sure that next_item() never computes OOB pointers.

> +               if (test_item(p, arg, type)) {
> +                       found = 1;
> +                       break;
> +               }
> +
> +               p = next_item(p, arg, type);
> +       }
> +
> +       *pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
> +       return found;
> +}
> +
> +/*
> + * Search an NT_GNU_PROPERTY_TYPE_0 for the property of 'pr_type'.
> + */
> +static int find_property(u32 pr_type, u32 *property, struct file *file,
> +                        loff_t file_offset, unsigned long desc_size)
> +{
> +       u8 *buf;
> +       int buf_size;
> +
> +       u32 buf_pos;
> +       unsigned long read_size;
> +       unsigned long done;
> +       int found = 0;
> +       int ret = 0;
> +       u32 last_pr = 0;
> +
> +       *property = 0;
> +       buf_pos = 0;
> +
> +       buf_size = (desc_size > PAGE_SIZE) ? PAGE_SIZE : desc_size;

open-coded min(desc_size, PAGE_SIZE)

> +       buf = kmalloc(buf_size, GFP_KERNEL);
> +       if (!buf)
> +               return -ENOMEM;
> +
> +       for (done = 0; done < desc_size; done += buf_pos) {
> +               read_size = desc_size - done;
> +               if (read_size > buf_size)
> +                       read_size = buf_size;
> +
> +               ret = kernel_read(file, buf, read_size, &file_offset);
> +
> +               if (ret != read_size)
> +                       return (ret < 0) ? ret : -EIO;

This leaks the memory allocated for `buf`.

> +
> +               ret = 0;
> +               found = scan(buf, read_size, sizeof(struct gnu_property),
> +                            test_property, next_property,
> +                            &last_pr, pr_type, &buf_pos);
> +
> +               if ((!buf_pos) || found)
> +                       break;
> +
> +               file_offset += buf_pos - read_size;
> +       }
[...]
> +       kfree(buf);
> +       return ret;
> +}

