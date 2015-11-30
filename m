Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 894F36B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:22:16 -0500 (EST)
Received: by pacej9 with SMTP id ej9so179242246pac.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 01:22:16 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id 69si7836783pfa.190.2015.11.30.01.22.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 01:22:15 -0800 (PST)
Date: Mon, 30 Nov 2015 18:22:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 01/12] mm: support madvise(MADV_FREE)
Message-ID: <20151130092229.GA10745@bbox>
References: <1448865583-2446-1-git-send-email-minchan@kernel.org>
 <1448865583-2446-2-git-send-email-minchan@kernel.org>
 <565C06C9.7040906@nextfour.com>
MIME-Version: 1.0
In-Reply-To: <565C06C9.7040906@nextfour.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@nextfour.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>

On Mon, Nov 30, 2015 at 10:20:25AM +0200, Mika Penttil=E4 wrote:
> > +		 * If pmd isn't transhuge but the page is THP and
> > +		 * is owned by only this process, split it and
> > +		 * deactivate all pages.
> > +		 */
> > +		if (PageTransCompound(page)) {
> > +			if (page=5Fmapcount(page) !=3D 1)
> > +				goto out;
> > +			get=5Fpage(page);
> > +			if (!trylock=5Fpage(page)) {
> > +				put=5Fpage(page);
> > +				goto out;
> > +			}
> > +			pte=5Funmap=5Funlock(orig=5Fpte, ptl);
> > +			if (split=5Fhuge=5Fpage(page)) {
> > +				unlock=5Fpage(page);
> > +				put=5Fpage(page);
> > +				pte=5Foffset=5Fmap=5Flock(mm, pmd, addr, &ptl);
> > +				goto out;
> > +			}
> > +			pte =3D pte=5Foffset=5Fmap=5Flock(mm, pmd, addr, &ptl);
> > +			pte--;
> > +			addr -=3D PAGE=5FSIZE;
> > +			continue;
> > +		}
>=20
> looks like this leaks page count if split=5Fhuge=5Fpage() is succesfull
> (returns zero).

Even, I missed unlock=5Fpage.
Thanks for the review!
