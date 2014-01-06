Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 58B386B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 12:30:32 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so16202032wes.11
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 09:30:31 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id m9si2909921wic.34.2014.01.06.09.30.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 09:30:31 -0800 (PST)
Received: by mail-wi0-f182.google.com with SMTP id en1so3110161wid.3
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 09:30:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140106170855.GA1828@mguzik.redhat.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
	<1389022230-24664-3-git-send-email-wroberts@tresys.com>
	<20140106170855.GA1828@mguzik.redhat.com>
Date: Mon, 6 Jan 2014 09:30:31 -0800
Message-ID: <CAFftDdpoV9S5VO6Ozt3nOF+bnJDeomeOR5k8ri8eRBm3JrkXGQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] audit: Audit proc cmdline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, akpm@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>

On Mon, Jan 6, 2014 at 9:08 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> I can't comment on the concept, but have one nit.

FYI: The concept is something that has been in the works and at least ackd on
by the current maintainer of audit:
http://marc.info/?l=linux-kernel&m=138660320704580&w=2

>
> On Mon, Jan 06, 2014 at 07:30:30AM -0800, William Roberts wrote:
>> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct *tsk,
>> +                      struct audit_context *context)
>> +{
>> +     int res;
>> +     char *buf;
>> +     char *msg = "(null)";
>> +     audit_log_format(ab, " cmdline=");
>> +
>> +     /* Not  cached */
>> +     if (!context->cmdline) {
>> +             buf = kmalloc(PATH_MAX, GFP_KERNEL);
>> +             if (!buf)
>> +                     goto out;
>> +             res = get_cmdline(tsk, buf, PATH_MAX);
>> +             /* Ensure NULL terminated */
>> +             if (buf[res-1] != '\0')
>> +                     buf[res-1] = '\0';
>
> This accesses memory below the buffer if get_cmdline returned 0, which I
> believe will be the case when someone jokingly unmaps the area (all
> maybe when it is swapped out but can't be swapped in due to I/O errors).
>

Yeah that's not a nit, that's a serious issue and I will correct. Thanks.

> Also since you are just putting 0 in there anyway I don't see much point
> in testing for it.
>
>> +             context->cmdline = buf;
>> +     }
>> +     msg = context->cmdline;
>> +out:
>> +     audit_log_untrustedstring(ab, msg);
>> +}
>> +
>
>
>
> --
> Mateusz Guzik



-- 
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
