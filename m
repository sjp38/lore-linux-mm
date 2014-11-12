Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3BA6B00E8
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 08:18:04 -0500 (EST)
Received: by mail-vc0-f176.google.com with SMTP id la4so1016886vcb.35
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 05:18:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0a8539257086c2a3f7615d35ef621c7f81df52cf.1415636409.git.milosz@adfin.com>
References: <cover.1415636409.git.milosz@adfin.com>
	<0a8539257086c2a3f7615d35ef621c7f81df52cf.1415636409.git.milosz@adfin.com>
Date: Wed, 12 Nov 2014 18:48:02 +0530
Message-ID: <CANGLyW-ZV2qON++MA96RsjQ6-R2VT0NyhGXRd0GnDDgUcz0n1g@mail.gmail.com>
Subject: Re: [PATCH v6 2/7] vfs: Define new syscalls preadv2,pwritev2
From: mohanty bhagaban <bhagaban181@gmail.com>
Content-Type: multipart/alternative; boundary=20cf307f3880b382560507a939c2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: russel.david100@gmail.com
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Mel Gorman <mgorman@suse.de>, Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>, Jeff Moyer <jmoyer@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org

--20cf307f3880b382560507a939c2
Content-Type: text/plain; charset=UTF-8

Russel,

Will this new flag ,  affect to any  io_vector. and any buffer cache.

+SYSCALL_DEFINE6(preadv2, unsigned long, fd, const struct iovec __user *,
vec,
+               unsigned long, vlen, unsigned long, pos_l, unsigned long,
pos_h,
+               int flags)
+{
+       loff_t pos = pos_from_hilo(pos_h, pos_l);
+
+       if (pos == -1)
+               return do_readv(fd, vec, vlen, flags);
+
+       return do_preadv(fd, vec, vlen, pos, flags);
+}
+

Bhagaban





On Mon, Nov 10, 2014 at 10:10 PM, Milosz Tanski <milosz@adfin.com> wrote:

> New syscalls that take an flag argument. This change does not add any
> specific
> flags.
>
> Signed-off-by: Milosz Tanski <milosz@adfin.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/read_write.c                   | 172
> ++++++++++++++++++++++++++++++--------
>  include/linux/compat.h            |   6 ++
>  include/linux/syscalls.h          |   6 ++
>  include/uapi/asm-generic/unistd.h |   6 +-
>  mm/filemap.c                      |   5 +-
>  5 files changed, 156 insertions(+), 39 deletions(-)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 94b2d34..b1b4bc8 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -866,6 +866,8 @@ ssize_t vfs_readv(struct file *file, const struct
> iovec __user *vec,
>                 return -EBADF;
>         if (!(file->f_mode & FMODE_CAN_READ))
>                 return -EINVAL;
> +       if (flags & ~0)
> +               return -EINVAL;
>
>         return do_readv_writev(READ, file, vec, vlen, pos, flags);
>  }
> @@ -879,21 +881,23 @@ ssize_t vfs_writev(struct file *file, const struct
> iovec __user *vec,
>                 return -EBADF;
>         if (!(file->f_mode & FMODE_CAN_WRITE))
>                 return -EINVAL;
> +       if (flags & ~0)
> +               return -EINVAL;
>
>         return do_readv_writev(WRITE, file, vec, vlen, pos, flags);
>  }
>
>  EXPORT_SYMBOL(vfs_writev);
>
> -SYSCALL_DEFINE3(readv, unsigned long, fd, const struct iovec __user *,
> vec,
> -               unsigned long, vlen)
> +static ssize_t do_readv(unsigned long fd, const struct iovec __user *vec,
> +                       unsigned long vlen, int flags)
>  {
>         struct fd f = fdget_pos(fd);
>         ssize_t ret = -EBADF;
>
>         if (f.file) {
>                 loff_t pos = file_pos_read(f.file);
> -               ret = vfs_readv(f.file, vec, vlen, &pos, 0);
> +               ret = vfs_readv(f.file, vec, vlen, &pos, flags);
>                 if (ret >= 0)
>                         file_pos_write(f.file, pos);
>                 fdput_pos(f);
> @@ -905,15 +909,15 @@ SYSCALL_DEFINE3(readv, unsigned long, fd, const
> struct iovec __user *, vec,
>         return ret;
>  }
>
> -SYSCALL_DEFINE3(writev, unsigned long, fd, const struct iovec __user *,
> vec,
> -               unsigned long, vlen)
> +static ssize_t do_writev(unsigned long fd, const struct iovec __user *vec,
> +                        unsigned long vlen, int flags)
>  {
>         struct fd f = fdget_pos(fd);
>         ssize_t ret = -EBADF;
>
>         if (f.file) {
>                 loff_t pos = file_pos_read(f.file);
> -               ret = vfs_writev(f.file, vec, vlen, &pos, 0);
> +               ret = vfs_writev(f.file, vec, vlen, &pos, flags);
>                 if (ret >= 0)
>                         file_pos_write(f.file, pos);
>                 fdput_pos(f);
> @@ -931,10 +935,9 @@ static inline loff_t pos_from_hilo(unsigned long
> high, unsigned long low)
>         return (((loff_t)high << HALF_LONG_BITS) << HALF_LONG_BITS) | low;
>  }
>
> -SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct iovec __user *,
> vec,
> -               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h)
> +static ssize_t do_preadv(unsigned long fd, const struct iovec __user *vec,
> +                        unsigned long vlen, loff_t pos, int flags)
>  {
> -       loff_t pos = pos_from_hilo(pos_h, pos_l);
>         struct fd f;
>         ssize_t ret = -EBADF;
>
> @@ -945,7 +948,7 @@ SYSCALL_DEFINE5(preadv, unsigned long, fd, const
> struct iovec __user *, vec,
>         if (f.file) {
>                 ret = -ESPIPE;
>                 if (f.file->f_mode & FMODE_PREAD)
> -                       ret = vfs_readv(f.file, vec, vlen, &pos, 0);
> +                       ret = vfs_readv(f.file, vec, vlen, &pos, flags);
>                 fdput(f);
>         }
>
> @@ -955,10 +958,9 @@ SYSCALL_DEFINE5(preadv, unsigned long, fd, const
> struct iovec __user *, vec,
>         return ret;
>  }
>
> -SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *,
> vec,
> -               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h)
> +static ssize_t do_pwritev(unsigned long fd, const struct iovec __user
> *vec,
> +                         unsigned long vlen, loff_t pos, int flags)
>  {
> -       loff_t pos = pos_from_hilo(pos_h, pos_l);
>         struct fd f;
>         ssize_t ret = -EBADF;
>
> @@ -969,7 +971,7 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const
> struct iovec __user *, vec,
>         if (f.file) {
>                 ret = -ESPIPE;
>                 if (f.file->f_mode & FMODE_PWRITE)
> -                       ret = vfs_writev(f.file, vec, vlen, &pos, 0);
> +                       ret = vfs_writev(f.file, vec, vlen, &pos, flags);
>                 fdput(f);
>         }
>
> @@ -979,11 +981,63 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const
> struct iovec __user *, vec,
>         return ret;
>  }
>
> +SYSCALL_DEFINE3(readv, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen)
> +{
> +       return do_readv(fd, vec, vlen, 0);
> +}
> +
> +SYSCALL_DEFINE3(writev, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen)
> +{
> +       return do_writev(fd, vec, vlen, 0);
> +}
> +
> +SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h)
> +{
> +       loff_t pos = pos_from_hilo(pos_h, pos_l);
> +
> +       return do_preadv(fd, vec, vlen, pos, 0);
> +}
> +
> +SYSCALL_DEFINE6(preadv2, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h,
> +               int, flags)
> +{
> +       loff_t pos = pos_from_hilo(pos_h, pos_l);
> +
> +       if (pos == -1)
> +               return do_readv(fd, vec, vlen, flags);
> +
> +       return do_preadv(fd, vec, vlen, pos, flags);
> +}
> +
> +SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h)
> +{
> +       loff_t pos = pos_from_hilo(pos_h, pos_l);
> +
> +       return do_pwritev(fd, vec, vlen, pos, 0);
> +}
> +
> +SYSCALL_DEFINE6(pwritev2, unsigned long, fd, const struct iovec __user *,
> vec,
> +               unsigned long, vlen, unsigned long, pos_l, unsigned long,
> pos_h,
> +               int, flags)
> +{
> +       loff_t pos = pos_from_hilo(pos_h, pos_l);
> +
> +       if (pos == -1)
> +               return do_writev(fd, vec, vlen, flags);
> +
> +       return do_pwritev(fd, vec, vlen, pos, flags);
> +}
> +
>  #ifdef CONFIG_COMPAT
>
>  static ssize_t compat_do_readv_writev(int type, struct file *file,
>                                const struct compat_iovec __user *uvector,
> -                              unsigned long nr_segs, loff_t *pos)
> +                              unsigned long nr_segs, loff_t *pos, int
> flags)
>  {
>         compat_ssize_t tot_len;
>         struct iovec iovstack[UIO_FASTIOV];
> @@ -1017,7 +1071,7 @@ static ssize_t compat_do_readv_writev(int type,
> struct file *file,
>
>         if (iter_fn)
>                 ret = do_iter_readv_writev(file, type, iov, nr_segs,
> tot_len,
> -                                               pos, iter_fn, 0);
> +                                               pos, iter_fn, flags);
>         else if (fnv)
>                 ret = do_sync_readv_writev(file, iov, nr_segs, tot_len,
>                                                 pos, fnv);
> @@ -1041,7 +1095,7 @@ out:
>
>  static size_t compat_readv(struct file *file,
>                            const struct compat_iovec __user *vec,
> -                          unsigned long vlen, loff_t *pos)
> +                          unsigned long vlen, loff_t *pos, int flags)
>  {
>         ssize_t ret = -EBADF;
>
> @@ -1051,8 +1105,10 @@ static size_t compat_readv(struct file *file,
>         ret = -EINVAL;
>         if (!(file->f_mode & FMODE_CAN_READ))
>                 goto out;
> +       if (flags & ~0)
> +               goto out;
>
> -       ret = compat_do_readv_writev(READ, file, vec, vlen, pos);
> +       ret = compat_do_readv_writev(READ, file, vec, vlen, pos, flags);
>
>  out:
>         if (ret > 0)
> @@ -1061,9 +1117,9 @@ out:
>         return ret;
>  }
>
> -COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,
> -               const struct compat_iovec __user *,vec,
> -               compat_ulong_t, vlen)
> +static size_t __compat_sys_readv(compat_ulong_t fd,
> +                                const struct compat_iovec __user *vec,
> +                                compat_ulong_t vlen, int flags)
>  {
>         struct fd f = fdget_pos(fd);
>         ssize_t ret;
> @@ -1072,16 +1128,24 @@ COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,
>         if (!f.file)
>                 return -EBADF;
>         pos = f.file->f_pos;
> -       ret = compat_readv(f.file, vec, vlen, &pos);
> +       ret = compat_readv(f.file, vec, vlen, &pos, flags);
>         if (ret >= 0)
>                 f.file->f_pos = pos;
>         fdput_pos(f);
>         return ret;
> +
> +}
> +
> +COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,
> +               const struct compat_iovec __user *,vec,
> +               compat_ulong_t, vlen)
> +{
> +       return __compat_sys_readv(fd, vec, vlen, 0);
>  }
>
>  static long __compat_sys_preadv64(unsigned long fd,
>                                   const struct compat_iovec __user *vec,
> -                                 unsigned long vlen, loff_t pos)
> +                                 unsigned long vlen, loff_t pos, int
> flags)
>  {
>         struct fd f;
>         ssize_t ret;
> @@ -1093,7 +1157,7 @@ static long __compat_sys_preadv64(unsigned long fd,
>                 return -EBADF;
>         ret = -ESPIPE;
>         if (f.file->f_mode & FMODE_PREAD)
> -               ret = compat_readv(f.file, vec, vlen, &pos);
> +               ret = compat_readv(f.file, vec, vlen, &pos, flags);
>         fdput(f);
>         return ret;
>  }
> @@ -1103,7 +1167,7 @@ COMPAT_SYSCALL_DEFINE4(preadv64, unsigned long, fd,
>                 const struct compat_iovec __user *,vec,
>                 unsigned long, vlen, loff_t, pos)
>  {
> -       return __compat_sys_preadv64(fd, vec, vlen, pos);
> +       return __compat_sys_preadv64(fd, vec, vlen, pos, 0);
>  }
>  #endif
>
> @@ -1113,12 +1177,25 @@ COMPAT_SYSCALL_DEFINE5(preadv, compat_ulong_t, fd,
>  {
>         loff_t pos = ((loff_t)pos_high << 32) | pos_low;
>
> -       return __compat_sys_preadv64(fd, vec, vlen, pos);
> +       return __compat_sys_preadv64(fd, vec, vlen, pos, 0);
> +}
> +
> +COMPAT_SYSCALL_DEFINE6(preadv2, compat_ulong_t, fd,
> +               const struct compat_iovec __user *,vec,
> +               compat_ulong_t, vlen, u32, pos_low, u32, pos_high,
> +               int, flags)
> +{
> +       loff_t pos = ((loff_t)pos_high << 32) | pos_low;
> +
> +       if (pos == -1)
> +               return __compat_sys_readv(fd, vec, vlen, flags);
> +
> +       return __compat_sys_preadv64(fd, vec, vlen, pos, flags);
>  }
>
>  static size_t compat_writev(struct file *file,
>                             const struct compat_iovec __user *vec,
> -                           unsigned long vlen, loff_t *pos)
> +                           unsigned long vlen, loff_t *pos, int flags)
>  {
>         ssize_t ret = -EBADF;
>
> @@ -1128,8 +1205,10 @@ static size_t compat_writev(struct file *file,
>         ret = -EINVAL;
>         if (!(file->f_mode & FMODE_CAN_WRITE))
>                 goto out;
> +       if (flags & ~0)
> +               goto out;
>
> -       ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos);
> +       ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos, flags);
>
>  out:
>         if (ret > 0)
> @@ -1138,9 +1217,9 @@ out:
>         return ret;
>  }
>
> -COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,
> -               const struct compat_iovec __user *, vec,
> -               compat_ulong_t, vlen)
> +static size_t __compat_sys_writev(compat_ulong_t fd,
> +                                 const struct compat_iovec __user* vec,
> +                                 compat_ulong_t vlen, int flags)
>  {
>         struct fd f = fdget_pos(fd);
>         ssize_t ret;
> @@ -1149,28 +1228,36 @@ COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,
>         if (!f.file)
>                 return -EBADF;
>         pos = f.file->f_pos;
> -       ret = compat_writev(f.file, vec, vlen, &pos);
> +       ret = compat_writev(f.file, vec, vlen, &pos, flags);
>         if (ret >= 0)
>                 f.file->f_pos = pos;
>         fdput_pos(f);
>         return ret;
>  }
>
> +COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,
> +               const struct compat_iovec __user *, vec,
> +               compat_ulong_t, vlen)
> +{
> +       return __compat_sys_writev(fd, vec, vlen, 0);
> +}
> +
>  static long __compat_sys_pwritev64(unsigned long fd,
>                                    const struct compat_iovec __user *vec,
> -                                  unsigned long vlen, loff_t pos)
> +                                  unsigned long vlen, loff_t pos, int
> flags)
>  {
>         struct fd f;
>         ssize_t ret;
>
>         if (pos < 0)
>                 return -EINVAL;
> +
>         f = fdget(fd);
>         if (!f.file)
>                 return -EBADF;
>         ret = -ESPIPE;
>         if (f.file->f_mode & FMODE_PWRITE)
> -               ret = compat_writev(f.file, vec, vlen, &pos);
> +               ret = compat_writev(f.file, vec, vlen, &pos, flags);
>         fdput(f);
>         return ret;
>  }
> @@ -1180,7 +1267,7 @@ COMPAT_SYSCALL_DEFINE4(pwritev64, unsigned long, fd,
>                 const struct compat_iovec __user *,vec,
>                 unsigned long, vlen, loff_t, pos)
>  {
> -       return __compat_sys_pwritev64(fd, vec, vlen, pos);
> +       return __compat_sys_pwritev64(fd, vec, vlen, pos, 0);
>  }
>  #endif
>
> @@ -1190,8 +1277,21 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,
>  {
>         loff_t pos = ((loff_t)pos_high << 32) | pos_low;
>
> -       return __compat_sys_pwritev64(fd, vec, vlen, pos);
> +       return __compat_sys_pwritev64(fd, vec, vlen, pos, 0);
> +}
> +
> +COMPAT_SYSCALL_DEFINE6(pwritev2, compat_ulong_t, fd,
> +               const struct compat_iovec __user *,vec,
> +               compat_ulong_t, vlen, u32, pos_low, u32, pos_high, int,
> flags)
> +{
> +       loff_t pos = ((loff_t)pos_high << 32) | pos_low;
> +
> +       if (pos == -1)
> +               return __compat_sys_writev(fd, vec, vlen, flags);
> +
> +       return __compat_sys_pwritev64(fd, vec, vlen, pos, flags);
>  }
> +
>  #endif
>
>  static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
> diff --git a/include/linux/compat.h b/include/linux/compat.h
> index e649426..63a94e2 100644
> --- a/include/linux/compat.h
> +++ b/include/linux/compat.h
> @@ -340,6 +340,12 @@ asmlinkage ssize_t compat_sys_preadv(compat_ulong_t
> fd,
>  asmlinkage ssize_t compat_sys_pwritev(compat_ulong_t fd,
>                 const struct compat_iovec __user *vec,
>                 compat_ulong_t vlen, u32 pos_low, u32 pos_high);
> +asmlinkage ssize_t compat_sys_preadv2(compat_ulong_t fd,
> +               const struct compat_iovec __user *vec,
> +               compat_ulong_t vlen, u32 pos_low, u32 pos_high, int flags);
> +asmlinkage ssize_t compat_sys_pwritev2(compat_ulong_t fd,
> +               const struct compat_iovec __user *vec,
> +               compat_ulong_t vlen, u32 pos_low, u32 pos_high, int flags);
>
>  #ifdef __ARCH_WANT_COMPAT_SYS_PREADV64
>  asmlinkage long compat_sys_preadv64(unsigned long fd,
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index bda9b81..cedc22e 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -571,8 +571,14 @@ asmlinkage long sys_pwrite64(unsigned int fd, const
> char __user *buf,
>                              size_t count, loff_t pos);
>  asmlinkage long sys_preadv(unsigned long fd, const struct iovec __user
> *vec,
>                            unsigned long vlen, unsigned long pos_l,
> unsigned long pos_h);
> +asmlinkage long sys_preadv2(unsigned long fd, const struct iovec __user
> *vec,
> +                           unsigned long vlen, unsigned long pos_l,
> unsigned long pos_h,
> +                           int flags);
>  asmlinkage long sys_pwritev(unsigned long fd, const struct iovec __user
> *vec,
>                             unsigned long vlen, unsigned long pos_l,
> unsigned long pos_h);
> +asmlinkage long sys_pwritev2(unsigned long fd, const struct iovec __user
> *vec,
> +                           unsigned long vlen, unsigned long pos_l,
> unsigned long pos_h,
> +                           int flags);
>  asmlinkage long sys_getcwd(char __user *buf, unsigned long size);
>  asmlinkage long sys_mkdir(const char __user *pathname, umode_t mode);
>  asmlinkage long sys_chdir(const char __user *filename);
> diff --git a/include/uapi/asm-generic/unistd.h
> b/include/uapi/asm-generic/unistd.h
> index 22749c1..9406018 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -213,6 +213,10 @@ __SC_COMP(__NR_pwrite64, sys_pwrite64,
> compat_sys_pwrite64)
>  __SC_COMP(__NR_preadv, sys_preadv, compat_sys_preadv)
>  #define __NR_pwritev 70
>  __SC_COMP(__NR_pwritev, sys_pwritev, compat_sys_pwritev)
> +#define __NR_preadv2 281
> +__SC_COMP(__NR_preadv2, sys_preadv2, compat_sys_preadv2)
> +#define __NR_pwritev2 282
> +__SC_COMP(__NR_pwritev2, sys_pwritev2, compat_sys_pwritev2)
>
>  /* fs/sendfile.c */
>  #define __NR3264_sendfile 71
> @@ -709,7 +713,7 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
>  __SYSCALL(__NR_bpf, sys_bpf)
>
>  #undef __NR_syscalls
> -#define __NR_syscalls 281
> +#define __NR_syscalls 283
>
>  /*
>   * All syscalls below here should go away really,
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 14b4642..530c263 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1457,6 +1457,7 @@ static void shrink_readahead_size_eio(struct file
> *filp,
>   * @ppos:      current file position
>   * @iter:      data destination
>   * @written:   already copied
> + * @flags:     optional flags
>   *
>   * This is a generic file read routine, and uses the
>   * mapping->a_ops->readpage() function for the actual low-level stuff.
> @@ -1465,7 +1466,7 @@ static void shrink_readahead_size_eio(struct file
> *filp,
>   * of the logic when it comes to error handling etc.
>   */
>  static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
> -               struct iov_iter *iter, ssize_t written)
> +               struct iov_iter *iter, ssize_t written, int flags)
>  {
>         struct address_space *mapping = filp->f_mapping;
>         struct inode *inode = mapping->host;
> @@ -1735,7 +1736,7 @@ generic_file_read_iter(struct kiocb *iocb, struct
> iov_iter *iter)
>                 }
>         }
>
> -       retval = do_generic_file_read(file, ppos, iter, retval);
> +       retval = do_generic_file_read(file, ppos, iter, retval,
> iocb->ki_rwflags);
>  out:
>         return retval;
>  }
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--20cf307f3880b382560507a939c2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Russel,<div><br></div><div>Will this new flag , =C2=A0affe=
ct to any =C2=A0io_vector. and any buffer cache.</div><div><br></div><div><=
span style=3D"font-family:arial,sans-serif;font-size:13px">+SYSCALL_DEFINE6=
(preadv2, unsigned long, fd, const struct iovec __user *, vec,</span><br st=
yle=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"font-fam=
ily:arial,sans-serif;font-size:13px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long, vlen, unsigned long, pos_l, unsigned lon=
g, pos_h,</span><br style=3D"font-family:arial,sans-serif;font-size:13px"><=
span style=3D"font-family:arial,sans-serif;font-size:13px">+=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int flags)</span><br style=3D"font=
-family:arial,sans-serif;font-size:13px"><span style=3D"font-family:arial,s=
ans-serif;font-size:13px">+{</span><br style=3D"font-family:arial,sans-seri=
f;font-size:13px"><span style=3D"font-family:arial,sans-serif;font-size:13p=
x">+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<=
/span><br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=
=3D"font-family:arial,sans-serif;font-size:13px">+</span><br style=3D"font-=
family:arial,sans-serif;font-size:13px"><span style=3D"font-family:arial,sa=
ns-serif;font-size:13px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (pos =3D=3D -1)</sp=
an><br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D=
"font-family:arial,sans-serif;font-size:13px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_readv(fd, vec, vlen, flags);</span><br=
 style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"font-=
family:arial,sans-serif;font-size:13px">+</span><br style=3D"font-family:ar=
ial,sans-serif;font-size:13px"><span style=3D"font-family:arial,sans-serif;=
font-size:13px">+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_preadv(fd, vec, vlen,=
 pos, flags);</span><br style=3D"font-family:arial,sans-serif;font-size:13p=
x"><span style=3D"font-family:arial,sans-serif;font-size:13px">+}</span><br=
 style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"font-=
family:arial,sans-serif;font-size:13px">+</span><br></div><div><br></div><d=
iv>Bhagaban</div><div><br></div><div><br></div><div><br></div><div><br></di=
v></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Mon, N=
ov 10, 2014 at 10:10 PM, Milosz Tanski <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:milosz@adfin.com" target=3D"_blank">milosz@adfin.com</a>&gt;</span> wro=
te:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex">New syscalls that take an flag argume=
nt. This change does not add any specific<br>
flags.<br>
<br>
Signed-off-by: Milosz Tanski &lt;<a href=3D"mailto:milosz@adfin.com">milosz=
@adfin.com</a>&gt;<br>
Reviewed-by: Christoph Hellwig &lt;<a href=3D"mailto:hch@lst.de">hch@lst.de=
</a>&gt;<br>
---<br>
=C2=A0fs/read_write.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| 172 ++++++++++++++++++++++++++++++--------<br>
=C2=A0include/linux/compat.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 =C2=A06 ++<br>
=C2=A0include/linux/syscalls.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =
=C2=A06 ++<br>
=C2=A0include/uapi/asm-generic/unistd.h |=C2=A0 =C2=A06 +-<br>
=C2=A0mm/filemap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A05 +-<br>
=C2=A05 files changed, 156 insertions(+), 39 deletions(-)<br>
<br>
diff --git a/fs/read_write.c b/fs/read_write.c<br>
index 94b2d34..b1b4bc8 100644<br>
--- a/fs/read_write.c<br>
+++ b/fs/read_write.c<br>
@@ -866,6 +866,8 @@ ssize_t vfs_readv(struct file *file, const struct iovec=
 __user *vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(file-&gt;f_mode &amp; FMODE_CAN_READ))<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags &amp; ~0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return do_readv_writev(READ, file, vec, vlen, p=
os, flags);<br>
=C2=A0}<br>
@@ -879,21 +881,23 @@ ssize_t vfs_writev(struct file *file, const struct io=
vec __user *vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(file-&gt;f_mode &amp; FMODE_CAN_WRITE))<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags &amp; ~0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return do_readv_writev(WRITE, file, vec, vlen, =
pos, flags);<br>
=C2=A0}<br>
<br>
=C2=A0EXPORT_SYMBOL(vfs_writev);<br>
<br>
-SYSCALL_DEFINE3(readv, unsigned long, fd, const struct iovec __user *, vec=
,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
)<br>
+static ssize_t do_readv(unsigned long fd, const struct iovec __user *vec,<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0unsigned long vlen, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f =3D fdget_pos(fd);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 loff_t pos =3D file=
_pos_read(f.file);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D vfs_readv(f=
.file, vec, vlen, &amp;pos, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D vfs_readv(f=
.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt;=3D 0)<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 file_pos_write(f.file, pos);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput_pos(f);<br>
@@ -905,15 +909,15 @@ SYSCALL_DEFINE3(readv, unsigned long, fd, const struc=
t iovec __user *, vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
-SYSCALL_DEFINE3(writev, unsigned long, fd, const struct iovec __user *, ve=
c,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
)<br>
+static ssize_t do_writev(unsigned long fd, const struct iovec __user *vec,=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 unsigned long vlen, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f =3D fdget_pos(fd);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 loff_t pos =3D file=
_pos_read(f.file);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D vfs_writev(=
f.file, vec, vlen, &amp;pos, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D vfs_writev(=
f.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt;=3D 0)<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 file_pos_write(f.file, pos);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput_pos(f);<br>
@@ -931,10 +935,9 @@ static inline loff_t pos_from_hilo(unsigned long high,=
 unsigned long low)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return (((loff_t)high &lt;&lt; HALF_LONG_BITS) =
&lt;&lt; HALF_LONG_BITS) | low;<br>
=C2=A0}<br>
<br>
-SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct iovec __user *, ve=
c,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h)<br>
+static ssize_t do_preadv(unsigned long fd, const struct iovec __user *vec,=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 unsigned long vlen, loff_t pos, int flags)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
@@ -945,7 +948,7 @@ SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct=
 iovec __user *, vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ESPIPE;<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file-&gt;f_mo=
de &amp; FMODE_PREAD)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D vfs_readv(f.file, vec, vlen, &amp;pos, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D vfs_readv(f.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
@@ -955,10 +958,9 @@ SYSCALL_DEFINE5(preadv, unsigned long, fd, const struc=
t iovec __user *, vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
-SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *, v=
ec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h)<br>
+static ssize_t do_pwritev(unsigned long fd, const struct iovec __user *vec=
,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0unsigned long vlen, loff_t pos, int flags)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
@@ -969,7 +971,7 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struc=
t iovec __user *, vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ESPIPE;<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file-&gt;f_mo=
de &amp; FMODE_PWRITE)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D vfs_writev(f.file, vec, vlen, &amp;pos, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0ret =3D vfs_writev(f.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
@@ -979,11 +981,63 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const str=
uct iovec __user *, vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
+SYSCALL_DEFINE3(readv, unsigned long, fd, const struct iovec __user *, vec=
,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_readv(fd, vec, vlen, 0);<br>
+}<br>
+<br>
+SYSCALL_DEFINE3(writev, unsigned long, fd, const struct iovec __user *, ve=
c,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_writev(fd, vec, vlen, 0);<br>
+}<br>
+<br>
+SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct iovec __user *, ve=
c,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_preadv(fd, vec, vlen, pos, 0);<br>
+}<br>
+<br>
+SYSCALL_DEFINE6(preadv2, unsigned long, fd, const struct iovec __user *, v=
ec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int, flags)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (pos =3D=3D -1)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return do_readv(fd,=
 vec, vlen, flags);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_preadv(fd, vec, vlen, pos, flags);<br=
>
+}<br>
+<br>
+SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *, v=
ec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_pwritev(fd, vec, vlen, pos, 0);<br>
+}<br>
+<br>
+SYSCALL_DEFINE6(pwritev2, unsigned long, fd, const struct iovec __user *, =
vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long, vlen=
, unsigned long, pos_l, unsigned long, pos_h,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int, flags)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D pos_from_hilo(pos_h, pos_l);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (pos =3D=3D -1)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return do_writev(fd=
, vec, vlen, flags);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return do_pwritev(fd, vec, vlen, pos, flags);<b=
r>
+}<br>
+<br>
=C2=A0#ifdef CONFIG_COMPAT<br>
<br>
=C2=A0static ssize_t compat_do_readv_writev(int type, struct file *file,<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat_iovec __user *uve=
ctor,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_segs, loff_t *pos)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_segs, loff_t *pos, int fla=
gs)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 compat_ssize_t tot_len;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct iovec iovstack[UIO_FASTIOV];<br>
@@ -1017,7 +1071,7 @@ static ssize_t compat_do_readv_writev(int type, struc=
t file *file,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (iter_fn)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D do_iter_rea=
dv_writev(file, type, iov, nr_segs, tot_len,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0pos, iter_fn, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0pos, iter_fn, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (fnv)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D do_sync_rea=
dv_writev(file, iov, nr_segs, tot_len,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 pos, fnv);<br>
@@ -1041,7 +1095,7 @@ out:<br>
<br>
=C2=A0static size_t compat_readv(struct file *file,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0const struct compat_iovec __user *vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned long vlen, loff_t *pos)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned long vlen, loff_t *pos, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
@@ -1051,8 +1105,10 @@ static size_t compat_readv(struct file *file,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(file-&gt;f_mode &amp; FMODE_CAN_READ))<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags &amp; ~0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_do_readv_writev(READ, file, vec,=
 vlen, pos);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_do_readv_writev(READ, file, vec,=
 vlen, pos, flags);<br>
<br>
=C2=A0out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt; 0)<br>
@@ -1061,9 +1117,9 @@ out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
-COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *,vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n)<br>
+static size_t __compat_sys_readv(compat_ulong_t fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat_iovec __user *ve=
c,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 compat_ulong_t vlen, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f =3D fdget_pos(fd);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret;<br>
@@ -1072,16 +1128,24 @@ COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!f.file)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pos =3D f.file-&gt;f_pos;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_readv(f.file, vec, vlen, &amp;po=
s);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_readv(f.file, vec, vlen, &amp;po=
s, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt;=3D 0)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f.file-&gt;f_pos =
=3D pos;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput_pos(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
+<br>
+}<br>
+<br>
+COMPAT_SYSCALL_DEFINE3(readv, compat_ulong_t, fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *,vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_readv(fd, vec, vlen, 0);<br=
>
=C2=A0}<br>
<br>
=C2=A0static long __compat_sys_preadv64(unsigned long fd,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat_iovec __u=
ser *vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, loff_t pos=
)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, loff_t pos=
, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret;<br>
@@ -1093,7 +1157,7 @@ static long __compat_sys_preadv64(unsigned long fd,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ESPIPE;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file-&gt;f_mode &amp; FMODE_PREAD)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_read=
v(f.file, vec, vlen, &amp;pos);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_read=
v(f.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
@@ -1103,7 +1167,7 @@ COMPAT_SYSCALL_DEFINE4(preadv64, unsigned long, fd,<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat=
_iovec __user *,vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long, vlen=
, loff_t, pos)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_preadv64(fd, vec, vlen, pos=
);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_preadv64(fd, vec, vlen, pos=
, 0);<br>
=C2=A0}<br>
=C2=A0#endif<br>
<br>
@@ -1113,12 +1177,25 @@ COMPAT_SYSCALL_DEFINE5(preadv, compat_ulong_t, fd,<=
br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 loff_t pos =3D ((loff_t)pos_high &lt;&lt; 32) |=
 pos_low;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_preadv64(fd, vec, vlen, pos=
);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_preadv64(fd, vec, vlen, pos=
, 0);<br>
+}<br>
+<br>
+COMPAT_SYSCALL_DEFINE6(preadv2, compat_ulong_t, fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *,vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n, u32, pos_low, u32, pos_high,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int, flags)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D ((loff_t)pos_high &lt;&lt; 32) |=
 pos_low;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (pos =3D=3D -1)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys=
_readv(fd, vec, vlen, flags);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_preadv64(fd, vec, vlen, pos=
, flags);<br>
=C2=A0}<br>
<br>
=C2=A0static size_t compat_writev(struct file *file,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat_iovec __user *vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, loff_t *pos)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, loff_t *pos, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EBADF;<br>
<br>
@@ -1128,8 +1205,10 @@ static size_t compat_writev(struct file *file,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(file-&gt;f_mode &amp; FMODE_CAN_WRITE))<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags &amp; ~0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_do_readv_writev(WRITE, file, vec=
, vlen, pos);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_do_readv_writev(WRITE, file, vec=
, vlen, pos, flags);<br>
<br>
=C2=A0out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt; 0)<br>
@@ -1138,9 +1217,9 @@ out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
-COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *, vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n)<br>
+static size_t __compat_sys_writev(compat_ulong_t fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat_iovec __us=
er* vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t vlen, int flags=
)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f =3D fdget_pos(fd);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret;<br>
@@ -1149,28 +1228,36 @@ COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!f.file)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pos =3D f.file-&gt;f_pos;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_writev(f.file, vec, vlen, &amp;p=
os);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_writev(f.file, vec, vlen, &amp;p=
os, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret &gt;=3D 0)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f.file-&gt;f_pos =
=3D pos;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput_pos(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
+COMPAT_SYSCALL_DEFINE3(writev, compat_ulong_t, fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *, vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_writev(fd, vec, vlen, 0);<b=
r>
+}<br>
+<br>
=C2=A0static long __compat_sys_pwritev64(unsigned long fd,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat_iov=
ec __user *vec,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long vlen, loff_t po=
s)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long vlen, loff_t po=
s, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct fd f;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ssize_t ret;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pos &lt; 0)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 f =3D fdget(fd);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!f.file)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBADF;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ESPIPE;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (f.file-&gt;f_mode &amp; FMODE_PWRITE)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_writ=
ev(f.file, vec, vlen, &amp;pos);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D compat_writ=
ev(f.file, vec, vlen, &amp;pos, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 fdput(f);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
@@ -1180,7 +1267,7 @@ COMPAT_SYSCALL_DEFINE4(pwritev64, unsigned long, fd,<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat=
_iovec __user *,vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long, vlen=
, loff_t, pos)<br>
=C2=A0{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_pwritev64(fd, vec, vlen, po=
s);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_pwritev64(fd, vec, vlen, po=
s, 0);<br>
=C2=A0}<br>
=C2=A0#endif<br>
<br>
@@ -1190,8 +1277,21 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,<=
br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 loff_t pos =3D ((loff_t)pos_high &lt;&lt; 32) |=
 pos_low;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_pwritev64(fd, vec, vlen, po=
s);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_pwritev64(fd, vec, vlen, po=
s, 0);<br>
+}<br>
+<br>
+COMPAT_SYSCALL_DEFINE6(pwritev2, compat_ulong_t, fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *,vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t, vle=
n, u32, pos_low, u32, pos_high, int, flags)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0loff_t pos =3D ((loff_t)pos_high &lt;&lt; 32) |=
 pos_low;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (pos =3D=3D -1)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys=
_writev(fd, vec, vlen, flags);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return __compat_sys_pwritev64(fd, vec, vlen, po=
s, flags);<br>
=C2=A0}<br>
+<br>
=C2=A0#endif<br>
<br>
=C2=A0static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,<br>
diff --git a/include/linux/compat.h b/include/linux/compat.h<br>
index e649426..63a94e2 100644<br>
--- a/include/linux/compat.h<br>
+++ b/include/linux/compat.h<br>
@@ -340,6 +340,12 @@ asmlinkage ssize_t compat_sys_preadv(compat_ulong_t fd=
,<br>
=C2=A0asmlinkage ssize_t compat_sys_pwritev(compat_ulong_t fd,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct compat=
_iovec __user *vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 compat_ulong_t vlen=
, u32 pos_low, u32 pos_high);<br>
+asmlinkage ssize_t compat_sys_preadv2(compat_ulong_t fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t vlen=
, u32 pos_low, u32 pos_high, int flags);<br>
+asmlinkage ssize_t compat_sys_pwritev2(compat_ulong_t fd,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct compat=
_iovec __user *vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compat_ulong_t vlen=
, u32 pos_low, u32 pos_high, int flags);<br>
<br>
=C2=A0#ifdef __ARCH_WANT_COMPAT_SYS_PREADV64<br>
=C2=A0asmlinkage long compat_sys_preadv64(unsigned long fd,<br>
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h<br>
index bda9b81..cedc22e 100644<br>
--- a/include/linux/syscalls.h<br>
+++ b/include/linux/syscalls.h<br>
@@ -571,8 +571,14 @@ asmlinkage long sys_pwrite64(unsigned int fd, const ch=
ar __user *buf,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t count, loff_t pos);<br>
=C2=A0asmlinkage long sys_preadv(unsigned long fd, const struct iovec __use=
r *vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, unsigned long pos_l, unsigned l=
ong pos_h);<br>
+asmlinkage long sys_preadv2(unsigned long fd, const struct iovec __user *v=
ec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, unsigned long pos_l, unsigned l=
ong pos_h,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0int flags);<br>
=C2=A0asmlinkage long sys_pwritev(unsigned long fd, const struct iovec __us=
er *vec,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long vlen, unsigned long pos_l, unsigned =
long pos_h);<br>
+asmlinkage long sys_pwritev2(unsigned long fd, const struct iovec __user *=
vec,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned long vlen, unsigned long pos_l, unsigned l=
ong pos_h,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0int flags);<br>
=C2=A0asmlinkage long sys_getcwd(char __user *buf, unsigned long size);<br>
=C2=A0asmlinkage long sys_mkdir(const char __user *pathname, umode_t mode);=
<br>
=C2=A0asmlinkage long sys_chdir(const char __user *filename);<br>
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/u=
nistd.h<br>
index 22749c1..9406018 100644<br>
--- a/include/uapi/asm-generic/unistd.h<br>
+++ b/include/uapi/asm-generic/unistd.h<br>
@@ -213,6 +213,10 @@ __SC_COMP(__NR_pwrite64, sys_pwrite64, compat_sys_pwri=
te64)<br>
=C2=A0__SC_COMP(__NR_preadv, sys_preadv, compat_sys_preadv)<br>
=C2=A0#define __NR_pwritev 70<br>
=C2=A0__SC_COMP(__NR_pwritev, sys_pwritev, compat_sys_pwritev)<br>
+#define __NR_preadv2 281<br>
+__SC_COMP(__NR_preadv2, sys_preadv2, compat_sys_preadv2)<br>
+#define __NR_pwritev2 282<br>
+__SC_COMP(__NR_pwritev2, sys_pwritev2, compat_sys_pwritev2)<br>
<br>
=C2=A0/* fs/sendfile.c */<br>
=C2=A0#define __NR3264_sendfile 71<br>
@@ -709,7 +713,7 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)<br>
=C2=A0__SYSCALL(__NR_bpf, sys_bpf)<br>
<br>
=C2=A0#undef __NR_syscalls<br>
-#define __NR_syscalls 281<br>
+#define __NR_syscalls 283<br>
<br>
=C2=A0/*<br>
=C2=A0 * All syscalls below here should go away really,<br>
diff --git a/mm/filemap.c b/mm/filemap.c<br>
index 14b4642..530c263 100644<br>
--- a/mm/filemap.c<br>
+++ b/mm/filemap.c<br>
@@ -1457,6 +1457,7 @@ static void shrink_readahead_size_eio(struct file *fi=
lp,<br>
=C2=A0 * @ppos:=C2=A0 =C2=A0 =C2=A0 current file position<br>
=C2=A0 * @iter:=C2=A0 =C2=A0 =C2=A0 data destination<br>
=C2=A0 * @written:=C2=A0 =C2=A0already copied<br>
+ * @flags:=C2=A0 =C2=A0 =C2=A0optional flags<br>
=C2=A0 *<br>
=C2=A0 * This is a generic file read routine, and uses the<br>
=C2=A0 * mapping-&gt;a_ops-&gt;readpage() function for the actual low-level=
 stuff.<br>
@@ -1465,7 +1466,7 @@ static void shrink_readahead_size_eio(struct file *fi=
lp,<br>
=C2=A0 * of the logic when it comes to error handling etc.<br>
=C2=A0 */<br>
=C2=A0static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,<=
br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct iov_iter *it=
er, ssize_t written)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct iov_iter *it=
er, ssize_t written, int flags)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct address_space *mapping =3D filp-&gt;f_ma=
pping;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inode *inode =3D mapping-&gt;host;<br>
@@ -1735,7 +1736,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov=
_iter *iter)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0retval =3D do_generic_file_read(file, ppos, ite=
r, retval);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0retval =3D do_generic_file_read(file, ppos, ite=
r, retval, iocb-&gt;ki_rwflags);<br>
=C2=A0out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return retval;<br>
=C2=A0}<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.9.1<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-fsdeve=
l&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at=C2=A0 <a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
</font></span></blockquote></div><br></div>

--20cf307f3880b382560507a939c2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
