Date: Sun, 8 Jun 2003 14:25:46 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: 2.5.70-mm6
Message-ID: <20030608122546.GA18050@lst.de>
References: <20030607151440.6982d8c6.akpm@digeo.com> <873cilz9os.fsf@lapper.ihatent.com> <20030607175649.6bf3813b.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030607175649.6bf3813b.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alexander Hoogerhuis <alexh@ihatent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 07, 2003 at 05:56:49PM -0700, Andrew Morton wrote:
> > Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
> > spurious 8259A interrupt: IRQ7.
> > SCSI device sda: 490232832 512-byte hdwr sectors (250999 MB)
> > sda: cache data unavailable
> > sda: assuming drive cache: write through
> >  /dev/scsi/host0/bus0/target0/lun0: p1
> > devfs_mk_dir(scsi/host0/bus0/target0/lun0): could not append to dir: ea549820 "target0"
> 
> Maybe Christph can decode this one for us.

There's multiple gendisks with the same .devfs_name in scsi and we call
devfs_mk_dir on each of them.  I think the right fix is to let
devfs_mk_dir succeed on an existing directory.


--- 1.91/fs/devfs/base.c	Wed Jun  4 09:50:29 2003
+++ edited/fs/devfs/base.c	Sat Jun  7 16:09:26 2003
@@ -1684,7 +1684,10 @@
 	}
 
 	error = _devfs_append_entry(dir, de, &old);
-	if (error) {
+	if (error == -EEXIST) {
+		error = 0;
+		devfs_put(old);
+	} else if (error) {
 		PRINTK("(%s): could not append to dir: %p \"%s\"\n",
 				buf, dir, dir->name);
 		devfs_put(old);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
