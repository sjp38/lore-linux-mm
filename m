Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2ECA6B02B4
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 15:51:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w79so18140651wme.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 12:51:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w20si579883wrc.52.2017.06.02.12.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 12:51:02 -0700 (PDT)
Date: Fri, 2 Jun 2017 12:50:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
Message-Id: <20170602125059.66209870607085b84c257593@linux-foundation.org>
In-Reply-To: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri,  2 Jun 2017 18:03:22 +0300 "Mike Rapoport" <rppt@linux.vnet.ibm.com> wrote:

> PR_SET_THP_DISABLE has a rather subtle semantic. It doesn't affect any
> existing mapping because it only updated mm->def_flags which is a template
> for new mappings. The mappings created after prctl(PR_SET_THP_DISABLE) have
> VM_NOHUGEPAGE flag set.  This can be quite surprising for all those
> applications which do not do prctl(); fork() & exec() and want to control
> their own THP behavior.
> 
> Another usecase when the immediate semantic of the prctl might be useful is
> a combination of pre- and post-copy migration of containers with CRIU.  In
> this case CRIU populates a part of a memory region with data that was saved
> during the pre-copy stage. Afterwards, the region is registered with
> userfaultfd and CRIU expects to get page faults for the parts of the region
> that were not yet populated. However, khugepaged collapses the pages and
> the expected page faults do not occur.
> 
> In more general case, the prctl(PR_SET_THP_DISABLE) could be used as a
> temporary mechanism for enabling/disabling THP process wide.
> 
> Implementation wise, a new MMF_DISABLE_THP flag is added. This flag is
> tested when decision whether to use huge pages is taken either during page
> fault of at the time of THP collapse.
> 
> It should be noted, that the new implementation makes PR_SET_THP_DISABLE
> master override to any per-VMA setting, which was not the case previously.
>
> Fixes: a0715cc22601 ("mm, thp: add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE")

"Fixes" is a bit strong.  I'd say "alters".  And significantly altering
the runtime behaviour of a three-year-old interface is rather a worry,
no?

Perhaps we should be adding new prctl modes to select this new
behaviour and leave the existing PR_SET_THP_DISABLE behaviour as-is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
