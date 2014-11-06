Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 396826B00CB
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 16:50:26 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so1939992pde.32
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 13:50:26 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id h2si7125506pdk.90.2014.11.06.13.50.23
        for <linux-mm@kvack.org>;
        Thu, 06 Nov 2014 13:50:24 -0800 (PST)
Message-ID: <545BED0B.8000001@intel.com>
Date: Thu, 06 Nov 2014 13:50:03 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241451280.5308@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

Instead of all of these games with dropping and reacquiring mmap_sem and
adding other locks, or deferring the work, why don't we just do a
get_user_pages()?  Something along the lines of:

while (1) {
	ret = cmpxchg(addr)
	if (!ret)
		break;
	if (ret == -EFAULT)
		get_user_pages(addr);
}

Does anybody see a problem with that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
