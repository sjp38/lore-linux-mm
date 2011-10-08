Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C3AD26B002C
	for <linux-mm@kvack.org>; Sat,  8 Oct 2011 00:28:31 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p984SSBp013032
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 21:28:28 -0700
Received: from iaqq3 (iaqq3.prod.google.com [10.12.43.3])
	by wpaz33.hot.corp.google.com with ESMTP id p984SItm018236
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 21:28:27 -0700
Received: by iaqq3 with SMTP id q3so6106670iaq.7
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 21:28:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110071943060.13992@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071529110.15540@router.home>
	<alpine.DEB.2.00.1110071943060.13992@chino.kir.corp.google.com>
Date: Fri, 7 Oct 2011 21:28:18 -0700
Message-ID: <CANN689FHhkkWu+1b+rHqSDLiV9Pp=LX8-Xsab2o=uocwEOOOMA@mail.gmail.com>
Subject: Re: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Fri, Oct 7, 2011 at 7:45 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 7 Oct 2011, Christoph Lameter wrote:
>> - =A0 =A0 lru_add_drain_all(); =A0 =A0/* flush pagevec */
>> + =A0 =A0 if (flags & MCL_CURRENT)
>> + =A0 =A0 =A0 =A0 =A0 =A0 lru_add_drain_all(); =A0 =A0/* flush pagevec *=
/
>
> I understand the intention of lru_add_drain_all() to try to avoid a
> later failure when moving to the unevictable list and why flushing it's
> necessary for MCL_FUTURE, but I think this should be written
>
> =A0 =A0 =A0 =A0if (!(flags & MCL_FUTURE))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0...
>
> since flags may be extended sometime in the future.

When flags =3D=3D (MCL_CURRENT | MCL_FUTURE), we do want to flush the
pagevecs as in the straight MCL_CURRENT case, so I think Christoph's
version is the correct one.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
