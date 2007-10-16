From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] rewrite ramdisk
Date: Tue, 16 Oct 2007 18:07:40 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710161747.12968.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710160945110.10197@fbirervta.pbzchgretzou.qr>
In-Reply-To: <Pine.LNX.4.64.0710160945110.10197@fbirervta.pbzchgretzou.qr>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161807.41157.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 17:52, Jan Engelhardt wrote:
> On Oct 16 2007 17:47, Nick Piggin wrote:
> >Here's a quick first hack...
>
> Inline patches preferred ;-)

Thanks for reviewing it anyway ;)


> >+config BLK_DEV_BRD
> >+	tristate "RAM block device support"
> >+	---help---
> >+	  This is a new  based block driver that replaces BLK_DEV_RAM.
>
> based on what?         -^

RAM based.


> >+	  To compile this driver as a module, choose M here: the
> >+	  module will be called rd.
>
> called brd.ko.

Changed. But it will hopefully just completely replace rd.c,
so I will probably just rename it to rd.c at some point (and
change .config options to stay compatible). Unless someone
sees a problem with that?


> >+/*
> >+ * And now the modules code and kernel interface.
> >+ */
> >+static int rd_nr;
> >+static int rd_size = CONFIG_BLK_DEV_RAM_SIZE;
>
> Perhaps unsigned?
> Perhaps even long for rd_size?

I've taken most of that stuff out of rd.c in an effort to stay
back compatible. I don't know if it really matters to use long?


> >+module_param(rd_nr, int, 0);
> >+MODULE_PARM_DESC(rd_nr, "Maximum number of brd devices");
> >+module_param(rd_size, int, 0);
> >+MODULE_PARM_DESC(rd_size, "Size of each RAM disk in kbytes.");
> >+MODULE_LICENSE("GPL");
> >+MODULE_ALIAS_BLOCKDEV_MAJOR(RAMDISK_MAJOR);
> >+
> >+/* options - nonmodular */
> >+#ifndef MODULE
> >+static int __init ramdisk_size(char *str)
> >+{
> >+	rd_size = simple_strtol(str,NULL,0);
> >+	return 1;
> >+}
>
> Is this, besides for compatibility, really needed?
>
> >+static int __init ramdisk_size2(char *str)
> >+{
> >+	return ramdisk_size(str);
> >+}
> >+static int __init rd_nr(char *str)
>
> Err! Overlapping symbols! The rd_nr() function collides with the rd_nr
> variable.

Thanks... %s gone awry. Fixed to the expected names.


> It also does not seem needed, since it did not exist before. 
> It should go, you can set the variable with brd.rd_nr=XXX (same
> goes for ramdisk_size).

But only if it's a module?


> What's the point of ramdisk_size2()? 

Back compat. When rewriting the internals, I want to try avoid
changing any externals if possible. Whether this is the Right
Way to do it or not, I don't know :P


> >+{
> >+	rd_nr = simple_strtol(str, NULL, 0);
> >+	return 1;
> >+}
> >+__setup("ramdisk=", ramdisk_size);
> >+__setup("ramdisk_size=", ramdisk_size2);
>
> __setup("ramdisk_size=", ramdisk_size); maybe, or does not that work?

Didn't try it, but the rd.c code does the same thing so I guess it
doesn't (or didn't, when it was written).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
