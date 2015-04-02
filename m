Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A02F86B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 22:05:07 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so69371773pac.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 19:05:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ko11si5238517pbd.90.2015.04.01.19.05.05
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 19:05:06 -0700 (PDT)
Date: Thu, 2 Apr 2015 10:04:43 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 481/507] kernel/sys.c:1713:19: sparse: incorrect type
 in initializer (different address spaces)
Message-ID: <201504021041.IXmhrcFg%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   c226e49f30453de9c6d82b001a985254990b32e0
commit: 3de343256baf44761d580e5bec367065d8f361f1 [481/507] prctl: avoid using mmap_sem for exe_file serialization
reproduce:
  # apt-get install sparse
  git checkout 3de343256baf44761d580e5bec367065d8f361f1
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   kernel/sys.c:886:49: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:886:49:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:886:49:    got unsigned long *<noident>
   kernel/sys.c:886:49: sparse: implicit cast to nocast type
   kernel/sys.c:886:59: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:886:59:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:886:59:    got unsigned long *<noident>
   kernel/sys.c:886:59: sparse: implicit cast to nocast type
   kernel/sys.c:948:32: sparse: incorrect type in argument 1 (different address spaces)
   kernel/sys.c:948:32:    expected struct task_struct *p1
   kernel/sys.c:948:32:    got struct task_struct [noderef] <asn:4>*real_parent
   kernel/sys.c:1550:25: sparse: implicit cast to nocast type
   kernel/sys.c:1553:49: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:1553:49:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:1553:49:    got unsigned long *<noident>
   kernel/sys.c:1553:49: sparse: implicit cast to nocast type
   kernel/sys.c:1553:57: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:1553:57:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:1553:57:    got unsigned long *<noident>
   kernel/sys.c:1553:57: sparse: implicit cast to nocast type
   kernel/sys.c:1579:51: sparse: incorrect type in argument 2 (different modifiers)
   kernel/sys.c:1579:51:    expected unsigned long [nocast] [usertype] *ut
   kernel/sys.c:1579:51:    got unsigned long *<noident>
   kernel/sys.c:1579:51: sparse: implicit cast to nocast type
   kernel/sys.c:1579:61: sparse: incorrect type in argument 3 (different modifiers)
   kernel/sys.c:1579:61:    expected unsigned long [nocast] [usertype] *st
   kernel/sys.c:1579:61:    got unsigned long *<noident>
   kernel/sys.c:1579:61: sparse: implicit cast to nocast type
>> kernel/sys.c:1713:19: sparse: incorrect type in initializer (different address spaces)
   kernel/sys.c:1713:19:    expected struct file [noderef] <asn:4>*__ret
   kernel/sys.c:1713:19:    got struct file *[assigned] file
>> kernel/sys.c:1713:17: sparse: incorrect type in assignment (different address spaces)
   kernel/sys.c:1713:17:    expected struct file *old_exe
   kernel/sys.c:1713:17:    got struct file [noderef] <asn:4>*[assigned] __ret
   kernel/sys.c:2043:16: sparse: incorrect type in argument 1 (different address spaces)
   kernel/sys.c:2043:16:    expected void const volatile [noderef] <asn:1>*<noident>
   kernel/sys.c:2043:16:    got int [noderef] <asn:1>**tid_addr

vim +1713 kernel/sys.c

  1547		unsigned long maxrss = 0;
  1548	
  1549		memset((char *)r, 0, sizeof (*r));
  1550		utime = stime = 0;
  1551	
  1552		if (who == RUSAGE_THREAD) {
> 1553			task_cputime_adjusted(current, &utime, &stime);
  1554			accumulate_thread_rusage(p, r);
  1555			maxrss = p->signal->maxrss;
  1556			goto out;
  1557		}
  1558	
  1559		if (!lock_task_sighand(p, &flags))
  1560			return;
  1561	
  1562		switch (who) {
  1563		case RUSAGE_BOTH:
  1564		case RUSAGE_CHILDREN:
  1565			utime = p->signal->cutime;
  1566			stime = p->signal->cstime;
  1567			r->ru_nvcsw = p->signal->cnvcsw;
  1568			r->ru_nivcsw = p->signal->cnivcsw;
  1569			r->ru_minflt = p->signal->cmin_flt;
  1570			r->ru_majflt = p->signal->cmaj_flt;
  1571			r->ru_inblock = p->signal->cinblock;
  1572			r->ru_oublock = p->signal->coublock;
  1573			maxrss = p->signal->cmaxrss;
  1574	
  1575			if (who == RUSAGE_CHILDREN)
  1576				break;
  1577	
  1578		case RUSAGE_SELF:
> 1579			thread_group_cputime_adjusted(p, &tgutime, &tgstime);
  1580			utime += tgutime;
  1581			stime += tgstime;
  1582			r->ru_nvcsw += p->signal->nvcsw;
  1583			r->ru_nivcsw += p->signal->nivcsw;
  1584			r->ru_minflt += p->signal->min_flt;
  1585			r->ru_majflt += p->signal->maj_flt;
  1586			r->ru_inblock += p->signal->inblock;
  1587			r->ru_oublock += p->signal->oublock;
  1588			if (maxrss < p->signal->maxrss)
  1589				maxrss = p->signal->maxrss;
  1590			t = p;
  1591			do {
  1592				accumulate_thread_rusage(t, r);
  1593			} while_each_thread(p, t);
  1594			break;
  1595	
  1596		default:
  1597			BUG();
  1598		}
  1599		unlock_task_sighand(p, &flags);
  1600	
  1601	out:
  1602		cputime_to_timeval(utime, &r->ru_utime);
  1603		cputime_to_timeval(stime, &r->ru_stime);
  1604	
  1605		if (who != RUSAGE_CHILDREN) {
  1606			struct mm_struct *mm = get_task_mm(p);
  1607	
  1608			if (mm) {
  1609				setmax_mm_hiwater_rss(&maxrss, mm);
  1610				mmput(mm);
  1611			}
  1612		}
  1613		r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */
  1614	}
  1615	
  1616	int getrusage(struct task_struct *p, int who, struct rusage __user *ru)
  1617	{
  1618		struct rusage r;
  1619	
  1620		k_getrusage(p, who, &r);
  1621		return copy_to_user(ru, &r, sizeof(r)) ? -EFAULT : 0;
  1622	}
  1623	
  1624	SYSCALL_DEFINE2(getrusage, int, who, struct rusage __user *, ru)
  1625	{
  1626		if (who != RUSAGE_SELF && who != RUSAGE_CHILDREN &&
  1627		    who != RUSAGE_THREAD)
  1628			return -EINVAL;
  1629		return getrusage(current, who, ru);
  1630	}
  1631	
  1632	#ifdef CONFIG_COMPAT
  1633	COMPAT_SYSCALL_DEFINE2(getrusage, int, who, struct compat_rusage __user *, ru)
  1634	{
  1635		struct rusage r;
  1636	
  1637		if (who != RUSAGE_SELF && who != RUSAGE_CHILDREN &&
  1638		    who != RUSAGE_THREAD)
  1639			return -EINVAL;
  1640	
  1641		k_getrusage(current, who, &r);
  1642		return put_compat_rusage(&r, ru);
  1643	}
  1644	#endif
  1645	
  1646	SYSCALL_DEFINE1(umask, int, mask)
  1647	{
  1648		mask = xchg(&current->fs->umask, mask & S_IRWXUGO);
  1649		return mask;
  1650	}
  1651	
  1652	static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
  1653	{
  1654		struct fd exe;
  1655		struct file *old_exe, *exe_file;
  1656		struct inode *inode;
  1657		int err;
  1658	
  1659		exe = fdget(fd);
  1660		if (!exe.file)
  1661			return -EBADF;
  1662	
  1663		inode = file_inode(exe.file);
  1664	
  1665		/*
  1666		 * Because the original mm->exe_file points to executable file, make
  1667		 * sure that this one is executable as well, to avoid breaking an
  1668		 * overall picture.
  1669		 */
  1670		err = -EACCES;
  1671		if (!S_ISREG(inode->i_mode)	||
  1672		    exe.file->f_path.mnt->mnt_flags & MNT_NOEXEC)
  1673			goto exit;
  1674	
  1675		err = inode_permission(inode, MAY_EXEC);
  1676		if (err)
  1677			goto exit;
  1678	
  1679		/*
  1680		 * Forbid mm->exe_file change if old file still mapped.
  1681		 */
  1682		exe_file = get_mm_exe_file(mm);
  1683		err = -EBUSY;
  1684		if (exe_file) {
  1685			struct vm_area_struct *vma;
  1686	
  1687			down_read(&mm->mmap_sem);
  1688			for (vma = mm->mmap; vma; vma = vma->vm_next) {
  1689				if (!vma->vm_file)
  1690					continue;
  1691				if (path_equal(&vma->vm_file->f_path,
  1692					       &exe_file->f_path))
  1693					goto exit_err;
  1694			}
  1695	
  1696			up_read(&mm->mmap_sem);
  1697			fput(exe_file);
  1698		}
  1699	
  1700		/*
  1701		 * The symlink can be changed only once, just to disallow arbitrary
  1702		 * transitions malicious software might bring in. This means one
  1703		 * could make a snapshot over all processes running and monitor
  1704		 * /proc/pid/exe changes to notice unusual activity if needed.
  1705		 */
  1706		err = -EPERM;
  1707		if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
  1708			goto exit;
  1709	
  1710		err = 0;
  1711		/* set the new file, lockless */
  1712		get_file(exe.file);
> 1713		old_exe = xchg(&mm->exe_file, exe.file);
  1714		if (old_exe)
  1715			fput(old_exe);
  1716	exit:

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
