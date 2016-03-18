Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 078D4828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 05:40:21 -0400 (EDT)
Received: by mail-qk0-f178.google.com with SMTP id x1so46493705qkc.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 02:40:21 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id 96si11541763qkw.52.2016.03.18.02.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 02:40:20 -0700 (PDT)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 18 Mar 2016 03:40:19 -0600
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id F0CB23E40048
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 03:40:14 -0600 (MDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2I9eEFu36372690
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:40:14 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2I9ZKbX002389
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 05:35:21 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 04/25] rmap: support file thp
In-Reply-To: <1457737157-38573-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <1457737157-38573-5-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 18 Mar 2016 15:10:06 +0530
Message-ID: <87d1qs9lah.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> [ text/plain ]
> Naive approach: on mapping/unmapping the page as compound we update
> ->_mapcount on each 4k page. That's not efficient, but it's not obvious
> how we can optimize this. We can look into optimization later.
>
> PG_double_map optimization doesn't work for file pages since lifecycle
> of file pages is different comparing to anon pages: file page can be
> mapped again at any time.
>

Can you explain this more ?. We added PG_double_map so that we can keep
page_remove_rmap simpler. So if it isn't a compound page we still can do

	if (!atomic_add_negative(-1, &page->_mapcount))

I am trying to understand why we can't use that with file pages ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
