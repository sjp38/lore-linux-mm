Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id A99CD6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 19:53:10 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so8492467ieb.4
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 16:53:10 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id rt1si10286703igb.43.2015.03.05.16.53.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 16:53:10 -0800 (PST)
Received: by iecar1 with SMTP id ar1so81639633iec.11
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 16:53:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425599692-32445-3-git-send-email-mgorman@suse.de>
References: <1425599692-32445-1-git-send-email-mgorman@suse.de>
	<1425599692-32445-3-git-send-email-mgorman@suse.de>
Date: Thu, 5 Mar 2015 16:53:09 -0800
Message-ID: <CA+55aFzdWE3dO8z6jUScft7=cLmE3x7G8Ak5dizfL=_z7puzaA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: numa: Do not clear PTEs or PMDs for NUMA hinting faults
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 5, 2015 at 3:54 PM, Mel Gorman <mgorman@suse.de> wrote:
>                 if (!prot_numa || !pmd_protnone(*pmd)) {
> -                       entry = pmdp_get_and_clear_notify(mm, addr, pmd);
> -                       entry = pmd_modify(entry, newprot);
> +                       /*
> +                        * NUMA hinting update can avoid a clear and defer the
> +                        * flush as it is not a functional correctness issue if
> +                        * access occurs after the update and this avoids
> +                        * spurious faults.
> +                        */
> +                       if (prot_numa) {
> +                               entry = *pmd;
> +                               entry = pmd_mkprotnone(entry);
> +                       } else {
> +                               entry = pmdp_get_and_clear_notify(mm, addr,
> +                                                                 pmd);
> +                               entry = pmd_modify(entry, newprot);
> +                               BUG_ON(pmd_write(entry));
> +                       }
> +
>                         ret = HPAGE_PMD_NR;
>                         set_pmd_at(mm, addr, pmd, entry);
> -                       BUG_ON(pmd_write(entry));

So I don't think this is right, nor is the new pte code.

You cannot just read the old pte entry, change it, and write it back.
That's fundamentally racy, and can drop any concurrent dirty or
accessed bit setting. And there are no locks you can use to protect
against that, since the accessed and dirty bit are set by hardware.

Now, losing the accessed bit doesn't matter - it's a small race, and
not a correctness issue. But potentially losing dirty bits is a data
loss problem.

Did the old prot_numa code do this too? Because if it did, it sounds
like it was just buggy.

                                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
