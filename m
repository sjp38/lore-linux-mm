Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 39D046B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:13:41 -0500 (EST)
Received: by mail-lf0-f46.google.com with SMTP id l143so37144563lfe.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:13:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id i19si4949873lfb.171.2016.02.11.10.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 10:13:39 -0800 (PST)
Subject: [PATCH] kvm: do not SetPageDirty from kvm_set_pfn_dirty for file
 mappings
From: Maxim Patlasov <mpatlasov@virtuozzo.com>
Date: Thu, 11 Feb 2016 10:13:29 -0800
Message-ID: <20160211181306.7864.44244.stgit@maxim-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com
Cc: kvm@vger.kernel.org, linux-nvdimm@lists.01.org, gleb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

The patch solves the following problem: file system specific routines
involved in ordinary routine writeback process BUG_ON page_buffers()
because a page goes to writeback without buffer-heads attached.

The way how kvm_set_pfn_dirty calls SetPageDirty works only for anon
mappings. For file mappings it is obviously incorrect - there page_mkwrite
must be called. It's not easy to add page_mkwrite call to kvm_set_pfn_dirty
because there is no universal way to find vma by pfn. But actually
SetPageDirty may be simply skipped in those cases. Below is a
justification.

When guest modifies the content of a page with file mapping, kernel kvm
makes the page dirty by the following call-path:

vmx_handle_exit ->
 handle_ept_violation ->
  __get_user_pages ->
   page_mkwrite ->
    SetPageDirty

Since then, the page is dirty from both guest and host point of view. Then
the host makes writeback and marks the page as write-protected. So any
further write from the guest triggers call-path above again.

So, for file mappings, it's not possible to have new data written to a page
inside the guest w/o corresponding SetPageDirty on the host.

This makes explicit SetPageDirty from kvm_set_pfn_dirty redundant.

Signed-off-by: Maxim Patlasov <mpatlasov@virtuozzo.com>
---
 virt/kvm/kvm_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index a11cfd2..5a7d3fa 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1582,7 +1582,8 @@ void kvm_set_pfn_dirty(kvm_pfn_t pfn)
 	if (!kvm_is_reserved_pfn(pfn)) {
 		struct page *page = pfn_to_page(pfn);
 
-		if (!PageReserved(page))
+		if (!PageReserved(page) &&
+		    (!page->mapping || PageAnon(page)))
 			SetPageDirty(page);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
