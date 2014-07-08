Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 61D9C6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 11:44:05 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so6120733wes.37
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 08:44:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hp10si6400313wjb.87.2014.07.08.08.44.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 08:44:03 -0700 (PDT)
Date: Tue, 8 Jul 2014 11:43:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 3/3] man2/fincore.2: document general description
 about fincore(2)
Message-ID: <20140708154303.GA22589@nhori.redhat.com>
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404756006-23794-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <53BAF01C.8010700@intel.com>
 <20140707205956.GB5031@nhori.bos.redhat.com>
 <53BB205E.5080801@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BB205E.5080801@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Jul 07, 2014 at 03:34:06PM -0700, Dave Hansen wrote:
> On 07/07/2014 01:59 PM, Naoya Horiguchi wrote:
> > On Mon, Jul 07, 2014 at 12:08:12PM -0700, Dave Hansen wrote:
> >> On 07/07/2014 11:00 AM, Naoya Horiguchi wrote:
> >>> +.SH RETURN VALUE
> >>> +On success,
> >>> +.BR fincore ()
> >>> +returns 0.
> >>> +On error, \-1 is returned, and
> >>> +.I errno
> >>> +is set appropriately.
> >>
> >> Is this accurate?  From reading the syscall itself, it looked like it
> >> did this:
> >>
> >>> + * Return value is the number of pages whose data is stored in fc->buffer.
> >>> + */
> >>> +static long do_fincore(struct fincore_control *fc, int nr_pages)
> >>
> >> and:
> >>
> >>> +SYSCALL_DEFINE6(fincore, int, fd, loff_t, start, long, nr_pages,
> >> ...
> >>> +	while (fc.nr_pages > 0) {
> >>> +		memset(fc.buffer, 0, fc.buffer_size);
> >>> +		ret = do_fincore(&fc, min(step, fc.nr_pages));
> >>> +		/* Reached the end of the file */
> >>> +		if (ret == 0)
> >>> +			break;
> >>> +		if (ret < 0)
> >>> +			break;
> >> ...
> >>> +	}
> >> ...
> >>> +	return ret;
> >>> +}
> >>
> >> Which seems that for a given loop of do_fincore(), you might end up
> >> returning the result of that *single* iteration of do_fincore() instead
> >> of the aggregate of the entire syscall.
> >>
> >> So, it can return <0 on failure, 0 on success, or also an essentially
> >> random >0 number on success too.
> > 
> > We don't break this while loop if do_fincore() returned a positive value
> > unless copy_to_user() fails. And in that case ret is set to -EFAULT.
> > So I think sys_fincore() never returns a positive value.
> 
> OK, that makes sense as I'm reading it again.
> 
> >> Why not just use the return value for something useful instead of
> >> hacking in the extras->nr_entries stuff?
> > 
> > Hmm, I got the opposite complaint previously, where we shouldn't
> > interpret the return value differently depending on the flag.
> > And I'd like to keep the extra argument for future extensibility.
> > For example, if we want to collect pages only with a specific
> > set of page flags, this extra argument will be necessary.
> 
> Couldn't it simply be the number of elements that it wrote in to the
> buffer, or even the number of bytes?

Yes, returning the number of elements looks clearer to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
