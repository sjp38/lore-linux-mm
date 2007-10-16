Date: Tue, 16 Oct 2007 09:52:52 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [patch][rfc] rewrite ramdisk
In-Reply-To: <200710161747.12968.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710160945110.10197@fbirervta.pbzchgretzou.qr>
References: <200710151028.34407.borntraeger@de.ibm.com>
 <m1abqjirmd.fsf@ebiederm.dsl.xmission.com> <200710161808.06405.nickpiggin@yahoo.com.au>
 <200710161747.12968.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Oct 16 2007 17:47, Nick Piggin wrote:
>
>Here's a quick first hack...

Inline patches preferred ;-)

>+config BLK_DEV_BRD
>+	tristate "RAM block device support"
>+	---help---
>+	  This is a new  based block driver that replaces BLK_DEV_RAM.

based on what?         -^

>+	  To compile this driver as a module, choose M here: the
>+	  module will be called rd.

called brd.ko.

>+/*
>+ * And now the modules code and kernel interface.
>+ */
>+static int rd_nr;
>+static int rd_size = CONFIG_BLK_DEV_RAM_SIZE;

Perhaps unsigned?
Perhaps even long for rd_size?

>+module_param(rd_nr, int, 0);
>+MODULE_PARM_DESC(rd_nr, "Maximum number of brd devices");
>+module_param(rd_size, int, 0);
>+MODULE_PARM_DESC(rd_size, "Size of each RAM disk in kbytes.");
>+MODULE_LICENSE("GPL");
>+MODULE_ALIAS_BLOCKDEV_MAJOR(RAMDISK_MAJOR);
>+
>+/* options - nonmodular */
>+#ifndef MODULE
>+static int __init ramdisk_size(char *str)
>+{
>+	rd_size = simple_strtol(str,NULL,0);
>+	return 1;
>+}

Is this, besides for compatibility, really needed?

>+static int __init ramdisk_size2(char *str)
>+{
>+	return ramdisk_size(str);
>+}
>+static int __init rd_nr(char *str)

Err! Overlapping symbols! The rd_nr() function collides with the rd_nr
variable. It also does not seem needed, since it did not exist before.
It should go, you can set the variable with brd.rd_nr=XXX (same
goes for ramdisk_size). What's the point of ramdisk_size2()?

>+{
>+	rd_nr = simple_strtol(str, NULL, 0);
>+	return 1;
>+}
>+__setup("ramdisk=", ramdisk_size);
>+__setup("ramdisk_size=", ramdisk_size2);

__setup("ramdisk_size=", ramdisk_size); maybe, or does not that work?

>+__setup("rd_nr=", rd_nr);
>+#endif
>+
>+
>+static struct brd_device *brd_alloc(int i)
>+{
>+	struct brd_device *brd;
>+	struct gendisk *disk;
>+
>+	brd = kzalloc(sizeof(*brd), GFP_KERNEL);
>+	if (!brd)
>+		goto out;
>+	brd->brd_number		= i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
