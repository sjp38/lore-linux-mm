Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 013156B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 23:15:47 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p543FhRk029767
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 20:15:44 -0700
Received: from gxk22 (gxk22.prod.google.com [10.202.11.22])
	by wpaz21.hot.corp.google.com with ESMTP id p543FcP1007477
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Jun 2011 20:15:42 -0700
Received: by gxk22 with SMTP id 22so1329091gxk.16
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 20:15:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110603115519.GI4061@linux.intel.com>
References: <20110603115519.GI4061@linux.intel.com>
Date: Fri, 3 Jun 2011 20:15:38 -0700
Message-ID: <BANLkTimc7wTyn0sVn+4OCL45_MOqhyV=QhJqV-GgXt_p290KwA@mail.gmail.com>
Subject: Re: Setting of the PageReadahed bit
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, Jun 3, 2011 at 4:55 AM, Matthew Wilcox <willy@linux.intel.com> wrot=
e:
> The exact definition of PageReadahead doesn't seem to be documented
> anywhere. =C2=A0I'm assuming it means "This page was not directly request=
ed;
> it is being read for prefetching purposes", exactly like the READA
> semantics.
>
> If my interpretation is correct, then the implementation in
> __do_page_cache_readahead is wrong:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_idx =3D=
=3D nr_to_read - lookahead_size)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0SetPageReadahead(page);
>
> It'll only set the PageReadahead bit on one page. =C2=A0The patch below f=
ixes
> this ... if my understanding is correct.

Incorrect I believe: it's a trigger to say, when you get this far,
it's time to think about kicking off the next read.

>
> If my understanding is wrong, then how are readpage/readpages
> implementations supposed to know that the VM is only prefetching these
> pages, and they're not as important as metadata (dependent) reads?

I don't think they do know at present; but I can well imagine there
may be advantage in them knowing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
