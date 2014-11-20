Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id CAA106B0071
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 10:18:35 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id a41so1420074yho.10
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 07:18:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c68si2909423qga.110.2014.11.20.07.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Nov 2014 07:18:34 -0800 (PST)
Message-ID: <546DFFA1.4030700@redhat.com>
Date: Thu, 20 Nov 2014 09:50:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
References: <502D42E5.7090403@redhat.com>	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>	<20120822032057.GA30871@google.com>	<50345232.4090002@redhat.com>	<20130603195003.GA31275@evergreen.ssec.wisc.edu>	<20141114163053.GA6547@cosmos.ssec.wisc.edu>	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>	<20141118014135.GA17252@cosmos.ssec.wisc.edu>	<546AB1F5.6030306@redhat.com>	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>	<CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>	<546BDB29.9050403@suse.cz>	<CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>	<546CC0CD.40906@suse.cz>	<CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>	<CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com> <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
In-Reply-To: <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Michel Lespinasse <walken@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:

> I'm thinking about limitation for reusing anon_vmas which might
> increase performance without breaking asymptotic estimation of
> count anon_vma in the worst case. For example this heuristic: allow
> to reuse only anon_vma with single direct descendant. It seems
> there will be arount up to two times more anon_vmas but
> false-aliasing must be much lower.

It may even be possible to not create a child anon_vma for the
first child a parent forks, but only create a new anon_vma once
the parent clones a second child (alive at the same time as the
first child).

That still takes care of things like apache or sendmail, but
would not create infinite anon_vmas for a task that keeps forking
itself to infinite depth without calling exec...

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUbf+hAAoJEM553pKExN6DxhQH/1QL+9GdhaSx7EQnRcbDRcHi
GuEfMU0g9Kv4ad+oPSQnH/L7vJMJAYeh5ZJGH+rOykWHp3sGReqDZOnzpXRAe11z
1cSC1BJsndzrv9wX8niFpuKpYbF0IP+ckv3qaEzWtm5yCRyhHVZfr6b794Y4K9jF
z2EPPu1vAAldbkx1VlYTwofBA5lESL5UmrFvH4ouI7BeWYSEe6BgVCbvK+K5fANT
ketdA5R08xyUAcXDa+28qpBYkdWnxNhwqseDoXCW8SOFNwWbLDI6GRfrsCNku13i
Gi41h3uEuIAGDf+AU/GMjiymgwutCOGq+cfZlszELaRvHmDpNGYdPv1llghNg7Q=
=Vk+H
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
