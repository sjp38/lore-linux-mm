Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDA66B0260
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:33:34 -0500 (EST)
Received: by wmvv187 with SMTP id v187so87011313wmv.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:33:34 -0800 (PST)
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com. [195.75.94.104])
        by mx.google.com with ESMTPS id 5si6178871wml.80.2015.11.13.07.33.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Nov 2015 07:33:33 -0800 (PST)
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 15:33:32 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id EF1C9219004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 15:33:25 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tADFXUPH7012736
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 15:33:30 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tADFXUMc003462
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:33:30 -0700
Received: from d50lp01.ny.us.ibm.com ([146.89.104.207])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id tADFXTGY001678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:33:30 -0700
Message-Id: <201511131533.tADFXTGY001678@d06av05.portsmouth.uk.ibm.com>
Received: from /spool/local
	by d50lp01.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 10:32:42 -0500
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 15:32:39 -0000
In-Reply-To: <alpine.DEB.2.20.1511130919240.15385@east.gentwo.org>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
From: "Andreas Krebbel1" <Andreas.Krebbel@de.ibm.com>
Date: Fri, 13 Nov 2015 16:32:33 +0100
References: <201511111413.65wysS6A%fengguang.wu@intel.com><20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
 <20151113125200.319a3101@mschwide>
 <201511131513.tADFDwJN030997@d06av03.portsmouth.uk.ibm.com>
 <alpine.DEB.2.20.1511130919240.15385@east.gentwo.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, heicars2@linux.vnet.ibm.com, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com

> On Fri, 13 Nov 2015, Andreas Krebbel1 wrote:
>=20
> > this appears to be the result of aligning struct page to more than 8=20
bytes
> > and putting it onto the stack - wich is only 8 bytes aligned.  The
> > compiler has to perform runtime alignment to achieve that. It=20
allocates
> > memory using *alloca* and does the math with the returned pointer. Our
> > dynamic stack allocation option basically only checks if there is an
> > alloca user.
>=20
> The slub uses of struct page only require an alignment of the page=20
struct
> on the stack to a word. So its fine.

Our compare and swap double hardware instruction unfortunately requires 16 =

byte alignment. That's probably the reason why this alignment has been=20
picked. So I don't think that we can easily get rid of it.

-Andreas-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
