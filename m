Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB21AwxF014326
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 18:10:58 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB21C9FQ165076
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 18:12:09 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB21C8Ur009351
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 18:12:09 -0700
Subject: Re: [RFC v10][PATCH 09/13] Restore open file descriprtors
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <49345086.4@cs.columbia.edu>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-10-git-send-email-orenl@cs.columbia.edu>
	 <20081128112745.GR28946@ZenIV.linux.org.uk>
	 <1228159324.2971.74.camel@nimitz> <49344C11.6090204@cs.columbia.edu>
	 <1228164873.2971.95.camel@nimitz>  <49345086.4@cs.columbia.edu>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 17:12:06 -0800
Message-Id: <1228180326.2971.128.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@ZenIV.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 16:00 -0500, Oren Laadan wrote:
> Dave Hansen wrote:
> > On Mon, 2008-12-01 at 15:41 -0500, Oren Laadan wrote:
> >>>>> +   fd = cr_attach_file(file);      /* no need to cleanup 'file' below */
> >>>>> +   if (fd < 0) {
> >>>>> +           filp_close(file, NULL);
> >>>>> +           ret = fd;
> >>>>> +           goto out;
> >>>>> +   }
> >>>>> +
> >>>>> +   /* register new <objref, file> tuple in hash table */
> >>>>> +   ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
> >>>>> +   if (ret < 0)
> >>>>> +           goto out;
> >>>> Who said that file still exists at that point?
> >> Correct. This call should move higher up befor ethe call to cr_attach_file()
> > 
> > Is that sufficient?  It seems like we're depending on the fd's reference
> > to the 'struct file' to keep it valid in the hash.  If something happens
> > to the fd (like the other thread messing with it) the 'struct file' can
> > still go away.
> > 
> > Shouldn't we do another get_file() for the hash's reference?
> 
> When a shared object is inserted to the hash we automatically take another
> reference to it (according to its type) for as long as it remains in the
> hash. See:  'cr_obj_ref_grab()' and 'cr_obj_ref_drop()'.  So by moving that
> call higher up, we protect the struct file.

We also need to document that we depend on this reference in the hash to
keep the object around.  Take a look at cr_read_fd_data().  Once that
cr_attach_file() has been performed, the only thing keeping the 'file'
around is the hash reference.  If someone happened to remove it from the
hash, the vfs_llseek() below would be bogus.

I don't know how we document that the hash is one-way: writes only and
no later deletions.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
