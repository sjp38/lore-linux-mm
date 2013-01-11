Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 91ADA6B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 18:53:35 -0500 (EST)
Received: by mail-vb0-f53.google.com with SMTP id b23so1989626vbz.12
        for <linux-mm@kvack.org>; Fri, 11 Jan 2013 15:53:34 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Jan 2013 15:53:34 -0800
Message-ID: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
Subject: huge zero page vs FOLL_DUMP
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

Hi,

follow_page() has code to return ERR_PTR(-EFAULT) when it encounters
the zero page and FOLL_DUMP flag is passed - this is used to avoid
dumping the zero page to disk when doing core dumps, and also by
munlock to avoid having potentially large number of threads trying to
munlock the zero page at once, which we can't reclaim anyway.

We don't have the corresponding logic when follow_page() encounters a
huge zero page. I think we should, preferably before 3.8. However, I
am slightly confused as to what to do for the munlock case, as the
huge zero page actually does seem to be reclaimable. My guess is that
we could still skip the munlocks, until the zero page is actually
reclaimed at which point we should check if we can munlock it.

Kirill, is this something you would have time to look into ?

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
