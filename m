Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C33A5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8204721473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LrHEjG0K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8204721473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77A4C6B000A; Thu, 13 Jun 2019 05:43:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 729E26B000C; Thu, 13 Jun 2019 05:43:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5547C6B000D; Thu, 13 Jun 2019 05:43:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DECC6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so14078703pfv.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b0eW2dMKelYlLaleRf5bDKha7L0ij82/1V9DJV7UjR4=;
        b=rmihczVrPdM5XQy+jrHjl/K7UpNNxDgk5QpdmidCVLkEe0OKyR7AFkBppPO6Aff2fX
         cdSWa92mVTv5sUuRCbeuW72JIWei8TYpAE8Wgo0jFP/jU+S/GuFIIqOfv+Yg3DYfDDvJ
         D77phtLeHXWmoUAcpQwaA83WyUH0cjnxePJ8jhLrgmTYmjxwxEi/ALfvWlTmubZPeBBi
         h7g+whHbMA7tdZmXBxWuvS2HvQRn05LNW2Q0p7DznxTWnQpr55/YsmkYeSHk1qy7PVef
         WoHCtTehUUO1pXJZpNg0419+cmRPM7NkG1z2bPTESckQQcYWocgH5uT4eLMX2Q4rRg2e
         aGYw==
X-Gm-Message-State: APjAAAWsJ5aG9Gpv0+Nk6WjkJ9i2mYNovtZxw79RkN9YjkwNSNPz4wN2
	+0uSwLHqShDlWF63YCVmqzZ9y6/STMGSRjISBKWHoyDSzqx6iElp1zNG3e7hb4A2IkShV4Fxbzz
	rpfpU/AxdMU6O4tf4JVVVjw/sMSVeIH8s4uXK5TwYZ2yhgxSCVtFBINLu4fL+258=
X-Received: by 2002:a63:b1d:: with SMTP id 29mr29663069pgl.103.1560419024730;
        Thu, 13 Jun 2019 02:43:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycZhiDFWaeYfs2LEdGUGnpbiq/m87gRf+xNgG54MIs0QzA9ATuBQbXaIuDe+m5cNfMhzOy
X-Received: by 2002:a63:b1d:: with SMTP id 29mr29662987pgl.103.1560419023919;
        Thu, 13 Jun 2019 02:43:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419023; cv=none;
        d=google.com; s=arc-20160816;
        b=v65AIzfnBtKZKtF1MybeA15PgBbG6+fOYlsSmxKzND6bihli1u+Gvub3ic5wwP3xP8
         VU/HOGWMsrBr3Ezj8i2i0jdm2TmZuoweGnNxeeTZiTyDTySutHHOl6WhOkOFquijsQV0
         +j5ExsgGWQElF+jPwy0uoe3NzcAGfnpnoZ4cV2uC3ak77STXf+wYJfV8i1YauQ6wNwBC
         zNwOXWkeNsIXQQr/iV0WvYlcFaDRj114GRgOKmLOhgDLP085Unij2nWiVeoYDBy/URHX
         tB6ZjTKEFJBy+a0H5nd46z/YGQXFF3IRu5cmq0MeOGErXJGGQARtZJn/8CkYbrX2OIq6
         6x4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=b0eW2dMKelYlLaleRf5bDKha7L0ij82/1V9DJV7UjR4=;
        b=im3pFPH4rx2qFFqETPsVEp5D2+Pf+G3qg6fkXVeS0u3kBTzSQbZXu4tdwfJu2gcz9c
         jLkrGzB6QAR6xiVZd14vlp1LynfxHDV5O1K4hP7wTYwJ/5+gwpIGogI8LB5LzJJ+eBIT
         C6e+bsN3iR7u4ZbmoEm7ECm1gjhTkbE3Yj0uZPOor7tkX7EEzMBpChYo7TGw5pOCwRKM
         IcJW2UIYtDCi3J0pRfJdAs0W2zD7JkGGIESUESVnLaE+LBBKVwQWMEVWUcyVLxitx2uo
         oQrrZ1vV/agI2pXm/aPqLsDdQfxT4HJdQjIPhM0vdVtJSe0wVJn9vsSwFwx7HkL4V0zz
         yc2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LrHEjG0K;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q2si2560817pjq.89.2019.06.13.02.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LrHEjG0K;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=b0eW2dMKelYlLaleRf5bDKha7L0ij82/1V9DJV7UjR4=; b=LrHEjG0Kdxjb47axcEbnVJ75Oj
	CqNf25lmlVLOJfKQkF3m/Ep/P6iJD6MgQry617Z97k4733kia2UZW5iJya7hxNJbAcFnBT8XQs3jc
	CWcfMFVkye1tAeuYF/JO0acUBeHn7/aMj/pyCQL4Xz4x4RtvNpeoZBzNSKTz/doY+OwHfJZybszCK
	DxEJpuNXgqckVp+x3E/8EpTeHSGafD299qd+qeRl4D7XeirEUJDqvk16JkpnMnHgojP24ZnE9OVua
	8L7QeBf5I1C+3AfNY+yeF9mDvABdV472xMWynVzOzMDJZAQqG1CbAp246zQp9OX7BwYZax0tpQTMs
	15lD1mDA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGi-0001ki-O6; Thu, 13 Jun 2019 09:43:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
Date: Thu, 13 Jun 2019 11:43:07 +0200
Message-Id: <20190613094326.24093-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

->mapping isn't even used by HMM users, and the field at the same offset
in the zone_device part of the union is declared as pad.  (Which btw is
rather confusing, as DAX uses ->pgmap and ->mapping from two different
sides of the union, but DAX doesn't use hmm_devmem_free).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 0c62426d1257..e1dc98407e7b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1347,8 +1347,6 @@ static void hmm_devmem_free(struct page *page, void *data)
 {
 	struct hmm_devmem *devmem = data;
 
-	page->mapping = NULL;
-
 	devmem->ops->free(devmem, page);
 }
 
-- 
2.20.1

