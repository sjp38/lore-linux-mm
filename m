Date: Mon, 17 Dec 2007 20:28:53 +0100 (CET)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: 1st version of azfs
In-Reply-To: <OFE16CCD4C.0757B0AF-ONC12573B4.00642BAC-C12573B4.0066FFDD@de.ibm.com>
Message-ID: <Pine.LNX.4.64.0712171958250.32270@fbirervta.pbzchgretzou.qr>
References: <OFE16CCD4C.0757B0AF-ONC12573B4.00642BAC-C12573B4.0066FFDD@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maxim Shchetynin <maxim@de.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arnd@arndb.de
List-ID: <linux-mm.kvack.org>

>+config AZ_FS
>+	tristate "AZFS filesystem support"
>+	default m

I do not think it should default to anything.

>+#define AZFS_SUPERBLOCK_FLAGS		MS_NOEXEC | \
>+					MS_SYNCHRONOUS | \
>+					MS_DIRSYNC | \
>+					MS_ACTIVE
>
>+#define AZFS_BDI_CAPABILITIES		BDI_CAP_NO_ACCT_DIRTY | \
>+					BDI_CAP_NO_WRITEBACK | \
>+					BDI_CAP_MAP_COPY | \
>+					BDI_CAP_MAP_DIRECT | \
>+					BDI_CAP_VMFLAGS
>+
>+#define AZFS_CACHE_FLAGS		SLAB_HWCACHE_ALIGN | \
>+					SLAB_RECLAIM_ACCOUNT | \
>+					SLAB_MEM_SPREAD
>+

Suggest () around the (MS_NOEXEC|...|...)

>+enum azfs_direction {
>+	AZFS_MMAP,
>+	AZFS_READ,
>+	AZFS_WRITE
>+};
>+
>+struct azfs_super {
>+	struct list_head		list;
>+	unsigned long			media_size;
>+	unsigned long			block_size;
>+	unsigned short			block_shift;
>+	unsigned long			sector_size;
>+	unsigned short			sector_shift;
>+	unsigned long			ph_addr;
>+	unsigned long			io_addr;
>+	struct block_device		*blkdev;
>+	struct dentry			*root;
>+	struct list_head		block_list;
>+	rwlock_t			lock;
>+};

Some of these probably should be sometypedef_t or so, to ensure they
have their minimum width on 32-bit. The struct also could have some
reordering to avoid needless padding.

>+struct azfs_block {
>+	struct list_head		list;
>+	unsigned long			id;
>+	unsigned long			count;
>+};
>+

Same. unsigned long <=> uint64_t might be needed/helpful/etc.

>+static struct azfs_super_list		super_list;
>+static struct kmem_cache		*azfs_znode_cache __read_mostly = NULL;
>+static struct kmem_cache		*azfs_block_cache __read_mostly = NULL;

NULL is implicit, drop it, save some bytes in the object file.

>+static int
>+azfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
>+{
>+	struct inode *inode;
>+
>+	inode = azfs_new_inode(dir->i_sb, dir, mode, dev);
>+	if (!inode)
>+		return -ENOSPC;
>+
>+	if (S_ISREG(mode))
>+		I2Z(inode)->size = 0;
>+
>+	dget(dentry);
>+	d_instantiate(dentry, inode);
>+
>+	return 0;
>+}

Either azfs_mknod(), azfs_new_inode() or init_special_inode() seems
to be missing settings ->size to 0 in the !S_IFREG case and
setting ->size to something good-looking for S_IFDIR.

>+/**
>+ * azfs_open - open() method for file_operations
>+ * @inode, @file: see file_operations methods
>+ */
>+static int
>+azfs_open(struct inode *inode, struct file *file)
>+{
>+	file->private_data = inode;
>+
>+	if (file->f_flags & O_TRUNC) {
>+		i_size_write(inode, 0);
>+		inode->i_op->truncate(inode);
>+	}
>+	if (file->f_flags & O_APPEND)
>+		inode->i_fop->llseek(file, 0, SEEK_END);
>+
>+	return 0;
>+}

This looks like duplicate code. Usually the generic fs functions take
care of that, including quota handling which seems to be missing
here if this is continuing to exist.

>+	page_prot = pgprot_val(vma->vm_page_prot);
>+	page_prot |= (_PAGE_NO_CACHE | _PAGE_RW);

redundant ().

>+			for_each_block(ding, &super->block_list) {
>+				if (!west && (ding->id + ding->count == id))
>+					west = ding;
>+				else if (!east && (id + count == ding->id))
>+					east = ding;
redundant().

>+static struct inode*
>+azfs_new_inode(struct super_block *sb, struct inode *dir, int mode, dev_t dev)
>+{
>+	struct inode *inode;
>+
>+	inode = new_inode(sb);
>+	if (!inode)
>+		return NULL;
>+
>+	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>+
>+	inode->i_mode = mode;
>+	if (dir) {
>+		dir->i_mtime = dir->i_ctime = inode->i_mtime;
>+		inode->i_uid = current->fsuid;
>+		if (dir->i_mode & S_ISGID) {
>+			if (S_ISDIR(mode))
>+				inode->i_mode |= S_ISGID;
>+			inode->i_gid = dir->i_gid;
>+		} else {
>+			inode->i_gid = current->fsgid;
>+		}
>+	} else {
>+		inode->i_uid = 0;
>+		inode->i_gid = 0;
>+	}

Why not fsuid/fsgid in the else case?

>+azfs_statfs(struct dentry *dentry, struct kstatfs *stat)
>+{
>[...]
>+	mutex_lock(&sb->s_lock);
>+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
>+		inodes++;
>+		blocks += inode->i_blocks;
>+	}
>+	mutex_unlock(&sb->s_lock);

Can this be improved somehow? If the list of inodes is long, doing
statvfs() may keep the filesystem real busy.

>+static struct super_operations azfs_ops = {
>+	.alloc_inode	= azfs_alloc_inode,
>+	.destroy_inode	= azfs_destroy_inode,
>+	.drop_inode	= generic_delete_inode,
>+	.delete_inode	= azfs_delete_inode,
>+	.statfs		= azfs_statfs
>+};

Trailing comma preferred.

>+azfs_fill_super(struct super_block *sb, void *data, int silent)
>+{
>+	if (!disk || !disk->queue) {
>+		printk(KERN_ERR "%s needs a block device which has a gendisk "
>+				"with a queue\n",
>+				AZFS_FILESYSTEM_NAME);
>+		return -ENOSYS;
>+	}

ENOSYS seems inappropriate.

>+	if (!get_device(disk->driverfs_dev)) {
>+		printk(KERN_ERR "%s cannot get reference to device driver\n",
>+				AZFS_FILESYSTEM_NAME);
>+		return -EFAULT;
>+	}

as does EFAULT.

>+static struct file_system_type azfs_fs = {
>+	.owner		= THIS_MODULE,
>+	.name		= AZFS_FILESYSTEM_NAME,

I see you have made plans to change the filesystem name :)

>+	.get_sb		= azfs_get_sb,
>+	.kill_sb	= azfs_kill_sb,
>+	.fs_flags	= AZFS_FILESYSTEM_FLAGS

or just replace these macros.

>+static int __init
>+azfs_init(void)
>+{

C'mon, that fits on one line.

>+	if (!azfs_znode_cache) {
>+		printk(KERN_ERR "Could not allocate inode cache for %s\n",
>+				AZFS_FILESYSTEM_NAME);

While we are at it,
		printk(KERN_ERR "Could not blafasel for " AZFS_FILESYSTEM_NAME "\n");
saves the extra argument.

>+{
>+	struct azfs_super *super, *PILZE;

Process forests, superblock mushrooms, GNOME desktop, what next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
