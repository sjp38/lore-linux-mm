Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36FA8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:18:06 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so2113050pls.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 11:18:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a8si19413104pgi.359.2019.01.23.11.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 Jan 2019 11:18:05 -0800 (PST)
Date: Wed, 23 Jan 2019 11:18:02 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of
 switches
Message-ID: <20190123191802.GB15311@bombadil.infradead.org>
References: <20190123110349.35882-1-keescook@chromium.org>
 <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com>
 <874l9z31c5.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874l9z31c5.fsf@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, intel-wired-lan@lists.osuosl.org, linux-fsdevel@vger.kernel.org, xen-devel@lists.xenproject.org, Laura Abbott <labbott@redhat.com>, linux-kbuild@vger.kernel.org, Alexander Popov <alex.popov@linux.com>

On Wed, Jan 23, 2019 at 04:17:30PM +0200, Jani Nikula wrote:
> Can't have:
> 
> 	switch (i) {
> 		int j;
> 	case 0:
>         	/* ... */
> 	}
> 
> because it can't be turned into:
> 
> 	switch (i) {
> 		int j = 0; /* not valid C */
> 	case 0:
>         	/* ... */
> 	}
> 
> but can have e.g.:
> 
> 	switch (i) {
> 	case 0:
> 		{
> 			int j = 0;
> 	        	/* ... */
> 		}
> 	}
> 
> I think Kees' approach of moving such variable declarations to the
> enclosing block scope is better than adding another nesting block.

Another nesting level would be bad, but I think this is OK:

	switch (i) {
	case 0: {
		int j = 0;
        	/* ... */
	}
	case 1: {
		void *p = q;
		/* ... */
	}
	}

I can imagine Kees' patch might have a bad effect on stack consumption,
unless GCC can be relied on to be smart enough to notice the
non-overlapping liveness of the vriables and use the same stack slots
for both.
