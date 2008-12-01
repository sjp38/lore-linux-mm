Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1KsMTr014757
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:54:22 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1KsksA066194
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:54:46 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1KsjL6030661
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:54:46 -0500
Subject: Re: [RFC v10][PATCH 09/13] Restore open file descriprtors
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <49344C11.6090204@cs.columbia.edu>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-10-git-send-email-orenl@cs.columbia.edu>
	 <20081128112745.GR28946@ZenIV.linux.org.uk>
	 <1228159324.2971.74.camel@nimitz>  <49344C11.6090204@cs.columbia.edu>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 12:54:33 -0800
Message-Id: <1228164873.2971.95.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: linux-api@vger.kernel.org, containers@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Al Viro <viro@ZenIV.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 15:41 -0500, Oren Laadan wrote:
> >>> +   fd = cr_attach_file(file);      /* no need to cleanup 'file' below */
> >>> +   if (fd < 0) {
> >>> +           filp_close(file, NULL);
> >>> +           ret = fd;
> >>> +           goto out;
> >>> +   }
> >>> +
> >>> +   /* register new <objref, file> tuple in hash table */
> >>> +   ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
> >>> +   if (ret < 0)
> >>> +           goto out;
> >> Who said that file still exists at that point?
> 
> Correct. This call should move higher up befor ethe call to cr_attach_file()

Is that sufficient?  It seems like we're depending on the fd's reference
to the 'struct file' to keep it valid in the hash.  If something happens
to the fd (like the other thread messing with it) the 'struct file' can
still go away.

Shouldn't we do another get_file() for the hash's reference?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
