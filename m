Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7196DC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF89A21721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:58:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF89A21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590B86B0006; Mon,  1 Jul 2019 15:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 540EE8E0003; Mon,  1 Jul 2019 15:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4325A8E0002; Mon,  1 Jul 2019 15:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8B46B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 15:58:12 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id d3so8167278pgc.9
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 12:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PBYL7uBjA5LkozdWqymdjXhXo0nOKUO6X4DeIa8ofO4=;
        b=Vs92jogLIrEOSjnyfqCJNWlBsd0WJp6OvVulI5t4VYvQW5Bmu0OWfQ6tu6H46vy3ZM
         sjfsiAYA6IPCLLVIjpPrnYA5pz5YH1Qa8/DIgV467lr3kT5nZ70Wl57BKuYQI1Cw4oNO
         q3ijb8tNRQpTBCQgAjZpZ4IxhmVpEzmEvj9Gol3ZFnzqOtCswBomtYglWvJGjoGI+QAC
         gTKDnJJjjaPI7BTFlwv1EL3etmzVZMa7mrTPeKAkhSQPp0JuJ76z0Y/oZIj0yL5ojzyu
         LpRZ3X6Jq4DgYa97H37PN+k7PUIdOYRqoWbFP7imjlq9pT2tebW0SeT2N1IPjS7PMkO6
         7VFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVeK7uEO39F30OB4QeIANwr065UCkvzqc1PfHKKMqY3F8bE8A3v
	CERxL7P4CFHuWT8+rTf1ngcTM5UaPpxbSn0HumGorcSOVy5152KEIKgY+GJ5/U8LrJER6+C9v3g
	HdY60uipu9bH8POH7ubDR5uQWKfTghB57/jGQegcT4E2+JX7amQVVldPWZlU5+Q9xtg==
X-Received: by 2002:a17:902:b591:: with SMTP id a17mr29889016pls.96.1562011091687;
        Mon, 01 Jul 2019 12:58:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwc3os5/t3MAGBgfx4AQa9JPlBHwNg4wA100Dueb9vgWebg0ceWw3A13OQQ0E/Ap0fz08D
X-Received: by 2002:a17:902:b591:: with SMTP id a17mr29888971pls.96.1562011090950;
        Mon, 01 Jul 2019 12:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562011090; cv=none;
        d=google.com; s=arc-20160816;
        b=oP/UxwwvLa3DFfjMTuexMlno+cWdnidiGx1ePQej9tfYPRRf/ZridFapHOgEH8eaoz
         Ipf7q7s/1UuLwL+bt1q4TBaNT93hvElvmmpJd0lSAQAQ7EfG0EeudoZsZ67wUp3apbcY
         ythNRGJ9cOcE0GbjZWtIZUalChO/tIA029ab6U3hzjxT0hRRHaH0anJK9qQTHwWgrIV9
         ew9dwOZlF1mj8XJ3Ro5W3g7RE8PETKGO7GYfqh18+LGgd9Fg5JQH936c+KZpjgk2aR45
         N5Crm2lBXqK2DzbGM2vlMFgabr/J7z5stnUN2chxOJb/gBTLcYdeo4jngN9tvpF+jjJs
         M8Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=PBYL7uBjA5LkozdWqymdjXhXo0nOKUO6X4DeIa8ofO4=;
        b=t70LihHtYEV6Rb6H+8Pp1VcHYwv9uYOhC8watLGJkspRn86jbcSLmG3Xty+IdPwMBH
         68lih5sjaG+RfGVy45hebt4PBKI9Mo2NFHJrNUsqLLO0Ln76fHSjQxOKcu0c3N+strgQ
         b+Eeo9fAoCDgx2Dc0Mj3axMpRxywUYhcJoh8uZQu1jjQ61+fwyOA04atDW6RQQx9E8iS
         sKh+L+Qrj2dMAaCMiIl64rIyEvxOuU+NVsnkZ8GT3cZ1GbgXJtNIRbXWGYasOEg5v1nh
         CTGwvheUeJemX2ry67ii2dd+4xfMew/mrPlXbqd1c5iLYTl7jNDgkPc/XA4k4yCn51MN
         +F/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h18si406106pjt.9.2019.07.01.12.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 12:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Jul 2019 12:58:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,440,1557212400"; 
   d="scan'208";a="361947448"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga005.fm.intel.com with ESMTP; 01 Jul 2019 12:58:09 -0700
Message-ID: <ddba04d98c31963784231869088a37fe3ccefd09.camel@intel.com>
Subject: Re: [RFC PATCH] binfmt_elf: Extract .note.gnu.property from an ELF
 file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin"
 <hpa@zytor.com>,  Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, 
 linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch
 <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd
 Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir
 Singh <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>, Cyrill
 Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,  Florian Weimer
 <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Date: Mon, 01 Jul 2019 12:49:51 -0700
In-Reply-To: <CAG48ez0rHHfcRgiVZf5FP0YOzxsXigvpg6ci790cmiN6PBwkhQ@mail.gmail.com>
References: <20190628172203.797-1-yu-cheng.yu@intel.com>
	 <CAG48ez0rHHfcRgiVZf5FP0YOzxsXigvpg6ci790cmiN6PBwkhQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-01 at 21:49 +0200, Jann Horn wrote:
> On Fri, Jun 28, 2019 at 7:30 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> [...]
> > In the discussion, we decided to look at only an ELF header's
> > PT_GNU_PROPERTY, which is a shortcut pointing to the file's
> > .note.gnu.property.
> > 
> > The Linux gABI extension draft is here:
> > 
> >     https://github.com/hjl-tools/linux-abi/wiki/linux-abi-draft.pdf.
> > 
> > A few existing CET-enabled binary files were built without
> > PT_GNU_PROPERTY; but those files' .note.gnu.property are checked by
> > ld-linux, not Linux.  The compatibility impact from this change is
> > therefore managable.
> > 
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > 
> > With this patch, if an arch needs to setup features from ELF properties,
> > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and specific
> > arch_parse_property() and arch_setup_property().
> 
> [...]
> > +typedef bool (test_item_fn)(void *buf, u32 *arg, u32 type);
> > +typedef void *(next_item_fn)(void *buf, u32 *arg, u32 type);
> > +
> > +static bool test_property(void *buf, u32 *max_type, u32 pr_type)
> > +{
> > +       struct gnu_property *pr = buf;
> > +
> > +       /*
> > +        * Property types must be in ascending order.
> > +        * Keep track of the max when testing each.
> > +        */
> > +       if (pr->pr_type > *max_type)
> > +               *max_type = pr->pr_type;
> > +
> > +       return (pr->pr_type == pr_type);
> > +}
> > +
> > +static void *next_property(void *buf, u32 *max_type, u32 pr_type)
> > +{
> > +       struct gnu_property *pr = buf;
> > +
> > +       if ((buf + sizeof(*pr) + pr->pr_datasz < buf) ||
> 
> This looks like UB to me, see below.
> 
> > +           (pr->pr_type > pr_type) ||
> > +           (pr->pr_type > *max_type))
> > +               return NULL;
> > +       else
> > +               return (buf + sizeof(*pr) + pr->pr_datasz);
> > +}
> > +
> > +/*
> > + * Scan 'buf' for a pattern; return true if found.
> > + * *pos is the distance from the beginning of buf to where
> > + * the searched item or the next item is located.
> > + */
> > +static int scan(u8 *buf, u32 buf_size, int item_size, test_item_fn
> > test_item,
> > +               next_item_fn next_item, u32 *arg, u32 type, u32 *pos)
> > +{
> > +       int found = 0;
> > +       u8 *p, *max;
> > +
> > +       max = buf + buf_size;
> > +       if (max < buf)
> > +               return 0;
> 
> How can this ever legitimately happen? If it can't, perhaps you meant
> to put a WARN_ON_ONCE() or something like that here?
> Also, computing out-of-bounds pointers is UB (section 6.5.6 of C99:
> "If both the pointer operand and the result point to elements of the
> same array object, or one past the last element of the array object,
> the evaluation shall not produce an overflow; otherwise, the behavior
> is undefined."), and if the addition makes the pointer wrap, that's
> certainly out of bounds; so I don't think this condition can trigger
> without UB.
> 
> > +
> > +       p = buf;
> > +
> > +       while ((p + item_size < max) && (p + item_size > buf)) {
> 
> Again, as far as I know, this is technically UB. Please rewrite this.
> For example, you could do something like:
> 
>     while (max - p >= item_size) {
> 
> and then make sure that next_item() never computes OOB pointers.
> 
> > +               if (test_item(p, arg, type)) {
> > +                       found = 1;
> > +                       break;
> > +               }
> > +
> > +               p = next_item(p, arg, type);
> > +       }
> > +
> > +       *pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
> > +       return found;
> > +}
> > +
> > +/*
> > + * Search an NT_GNU_PROPERTY_TYPE_0 for the property of 'pr_type'.
> > + */
> > +static int find_property(u32 pr_type, u32 *property, struct file *file,
> > +                        loff_t file_offset, unsigned long desc_size)
> > +{
> > +       u8 *buf;
> > +       int buf_size;
> > +
> > +       u32 buf_pos;
> > +       unsigned long read_size;
> > +       unsigned long done;
> > +       int found = 0;
> > +       int ret = 0;
> > +       u32 last_pr = 0;
> > +
> > +       *property = 0;
> > +       buf_pos = 0;
> > +
> > +       buf_size = (desc_size > PAGE_SIZE) ? PAGE_SIZE : desc_size;
> 
> open-coded min(desc_size, PAGE_SIZE)
> 
> > +       buf = kmalloc(buf_size, GFP_KERNEL);
> > +       if (!buf)
> > +               return -ENOMEM;
> > +
> > +       for (done = 0; done < desc_size; done += buf_pos) {
> > +               read_size = desc_size - done;
> > +               if (read_size > buf_size)
> > +                       read_size = buf_size;
> > +
> > +               ret = kernel_read(file, buf, read_size, &file_offset);
> > +
> > +               if (ret != read_size)
> > +                       return (ret < 0) ? ret : -EIO;
> 
> This leaks the memory allocated for `buf`.
> 
> > +
> > +               ret = 0;
> > +               found = scan(buf, read_size, sizeof(struct gnu_property),
> > +                            test_property, next_property,
> > +                            &last_pr, pr_type, &buf_pos);
> > +
> > +               if ((!buf_pos) || found)
> > +                       break;
> > +
> > +               file_offset += buf_pos - read_size;
> > +       }
> 
> [...]
> > +       kfree(buf);
> > +       return ret;
> > +}

I will fix these.

Thanks,
Yu-cheng

