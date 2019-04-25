Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F98EC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF5AD20891
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 16:20:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF5AD20891
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECEAD6B000A; Thu, 25 Apr 2019 12:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7EB46B000C; Thu, 25 Apr 2019 12:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E896B000D; Thu, 25 Apr 2019 12:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A132E6B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:20:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2so59973pge.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q3T/m6MGqtB8/N5J2I5YRjU1h/p2w1Mfl6pWFPWHHnw=;
        b=W6uKzakni1FgC2+GrVXPu7T8PRqUfKry56UxjZ09zn4L4P9rGfLn5tksgaxtG7H7q4
         hQPP8FS4xu/moeKALcIkicUy/HOqitzP0tAAB3VWgkMGhXhne6E5fxrHCT3aoIwheP74
         mo2j2ch3EnqMlkIaNqpIdCdX9+m5g6o+iCqs6HZhyME3ShUmxWsc4PNkeDBUiG1s6wHK
         n4XAyK3YlBHjArun4X62uYi1mPFDgJ8djMMvhiJQWn/8v1IKFCDEhJPwJZZbfwtpq+4T
         V0qQWwRc+dAjMkjEbQrP989yN4s5AdYPOJbzCHNQp6Y4O6INByn02Kq7Bykc41YZyhIp
         2AKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVBWvC+19oKZFNzVavpuuJkhRxindrA8pqqFXZ+AHIZam8tg7vd
	nS72h0EJJzxhfe40wERguAbGTPILfQyWAbCWN1cyyNYMJ8TmJGEtZpPWCkkodXpgu/xUvua3vXY
	Y+h2+eInbf8gNR90l22gGiDSKECjDFEguc0vJL5RHRtRVBOCuJjuILEw/l1j6mnf3cw==
X-Received: by 2002:a63:ff26:: with SMTP id k38mr38188735pgi.123.1556209257254;
        Thu, 25 Apr 2019 09:20:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQUk7SIqZzIOeCkMR431Ps71zGfhCnKaiPjhMOiBXUU0VTOjWhF8rOAEX6/Uan797AZMJ/
X-Received: by 2002:a63:ff26:: with SMTP id k38mr38188672pgi.123.1556209256555;
        Thu, 25 Apr 2019 09:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556209256; cv=none;
        d=google.com; s=arc-20160816;
        b=zwCUTCaGyuPbn4Wopx7vacg/Hx0GK5jlCTQZjZHTFnHXVroPso3cX/3aPqUQBKBm+w
         KVyRcJ0BaJnDieLonWRTEjrALexl2cYAoWHErgGcA01enARV7nU2I59/EJgGK8ZZz6dV
         uQ3W1yb68tciHRluq0jZJcLVd1P5CviZkkd/3Clbz3bj/LD96D4w4Up4dywmKRWlkiHf
         sPbvwgSv9cL6g7mEm+nrCMhpYRqs7bci87cv2BI7svoCPzpfPg4PAFmmgL2TuH5D+f++
         DEzNv+MPUX4cgUrZMrCRHnGBwT/ho598rFgFi/3wgX8zrOITJKDUhYVx97/90vHvCX2M
         Ouzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=q3T/m6MGqtB8/N5J2I5YRjU1h/p2w1Mfl6pWFPWHHnw=;
        b=kjlFHAs3KKJM/qVTdvpwC2cuhNYo62cYssoS16qImnJ79fyn4GSdkLbH5YrYKsXBZ1
         Tvt/KpVSy2CEfP0f/WbiPzKa5ibuXW+2cWvbx0Gicaa1FpBxIE9kO0pxv5izx7pQdRun
         7LQcJBBbMXwHaZgB0Ns0F4/fEUrSID+nPYjQgWvWO5Hj7PuXKhOI+4qHFIWnA51vwUSj
         wndW+5EQbAEwW1EOwYk4zi5xg9iY+kTE2TpvwUrwZVFc4Mxwjsn9kAGKfCgujJhe91id
         uKr5xR/xz4tgkBG9BNkXViN3EbDvIGi/l4R1fhWNV5VIu81+CykYst/Euo8qh63A/kvF
         mZBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n15si22035967pgg.308.2019.04.25.09.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 09:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 09:20:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="138791963"
Received: from yyu32-desk1.sc.intel.com ([10.144.155.177])
  by orsmga006.jf.intel.com with ESMTP; 25 Apr 2019 09:20:54 -0700
Message-ID: <61ca9af34259921452aaeea047016c598ef73c77.camel@intel.com>
Subject: Re: [RFC PATCH v6 22/26] x86/cet/shstk: ELF header parsing of
 Shadow Stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Date: Thu, 25 Apr 2019 09:20:44 -0700
In-Reply-To: <20190425153547.GG3567@e103592.cambridge.arm.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
	 <20181119214809.6086-23-yu-cheng.yu@intel.com>
	 <20190425110211.GZ3567@e103592.cambridge.arm.com>
	 <e7bbb51291434a9c8526d7b617929465d5784121.camel@intel.com>
	 <20190425153547.GG3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-25 at 16:35 +0100, Dave Martin wrote:
> On Thu, Apr 25, 2019 at 08:14:52AM -0700, Yu-cheng Yu wrote:
> > On Thu, 2019-04-25 at 12:02 +0100, Dave Martin wrote:
> > > [...]
> One other question: according to the draft spec at
> https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI, it
> looks like the .note.gnu.property section is supposed to be marked with
> SHF_ALLOC in object files.
> 
> I think that means that the linker will map it with a PT_LOAD entry in
> the program header table in addition to the PT_NOTE that describes the
> location of the note.  I need to check what the toolchain actually
> does.
> 
> If so, can we simply rely on the notes being already mapped, rather than
> needing to do additional I/O on the ELF file to fetch the notes?

Assuming that is mapped and we do copy_from_user, it will trigger page faults. 
I suspect in this case reading from the file is better?

Yu-cheng

