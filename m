Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 259466B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 05:22:05 -0400 (EDT)
Date: Tue, 2 Jul 2013 11:22:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130702092200.GB16815@dhcp22.suse.cz>
References: <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <20130701081056.GA4072@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon 01-07-13 18:10:56, Dave Chinner wrote:
> On Mon, Jul 01, 2013 at 09:50:05AM +0200, Michal Hocko wrote:
> > On Mon 01-07-13 11:25:58, Dave Chinner wrote:
> > > On Sun, Jun 30, 2013 at 08:33:49PM +0200, Michal Hocko wrote:
> > > > On Sat 29-06-13 12:55:09, Dave Chinner wrote:
> > > > > On Thu, Jun 27, 2013 at 04:54:11PM +0200, Michal Hocko wrote:
> > > > > > On Thu 27-06-13 09:24:26, Dave Chinner wrote:
> > > > > > > On Wed, Jun 26, 2013 at 10:15:09AM +0200, Michal Hocko wrote:
> > > > > > > > On Tue 25-06-13 12:27:54, Dave Chinner wrote:
> > > > > > > > > On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> > > > > > > > > > And again, another hang. It looks like the inode deletion never
> > > > > > > > > > finishes. The good thing is that I do not see any LRU related BUG_ONs
> > > > > > > > > > anymore. I am going to test with the other patch in the thread.
> > > > > > > > > > 
> > > > > > > > > > 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> > > > > > > > > > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > > > > > > > > > [<ffffffff8118525f>] iget_locked+0x4f/0x180
> > > > > > > > > > [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> > > > > > > > > > [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> > > > > > > > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > > > > > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > > > > > > > [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> > > > > > > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > > > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > > > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > > > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > > > > > > [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> > > > > > > > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > .....
> > > > Do you mean sysrq+t? It is attached. 
> > > > 
> > > > Btw. I was able to reproduce this again. The stuck processes were
> > > > sitting in the same traces for more than 28 hours without any change so
> > > > I do not think this is a temporal condition.
> > > > 
> > > > Traces of all processes in the D state:
> > > > 7561 [<ffffffffa029c03e>] xfs_iget+0xbe/0x190 [xfs]
> > > > [<ffffffffa02a8e98>] xfs_lookup+0xe8/0x110 [xfs]
> > > > [<ffffffffa029fad9>] xfs_vn_lookup+0x49/0x90 [xfs]
> > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > [<ffffffff8117815e>] do_last+0x2de/0x780
> > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > This looks like it may be equivalent to the ext4 trace above, though
> > > I'm not totally sure on that yet. Can you get me the line of code
> > > where the above code is sleeping - 'gdb> l *(xfs_iget+0xbe)' output
> > > is sufficient.
> > 
> > OK, this is a bit tricky because I have xfs built as a module so objdump
> > on xfs.ko shows nonsense
> >    19039:       e8 00 00 00 00          callq  1903e <xfs_iget+0xbe>
> >    1903e:       48 8b 75 c0             mov    -0x40(%rbp),%rsi
> > 
> > crash was more clever though and it says:
> > 0xffffffffa029c034 <xfs_iget+180>:      mov    $0x1,%edi
> > 0xffffffffa029c039 <xfs_iget+185>:      callq  0xffffffff815776d0
> > <schedule_timeout_uninterruptible>
> > /dev/shm/mhocko-build/BUILD/kernel-3.9.0mmotm+/fs/xfs/xfs_icache.c: 423
> > 0xffffffffa029c03e <xfs_iget+190>:      mov    -0x40(%rbp),%rsi
> > 
> > which maps to:
> > out_error_or_again:
> >         if (error == EAGAIN) {
> >                 delay(1);
> >                 goto again;
> >         }
> > 
> > So this looks like this path loops in goto again and out_error_or_again.
> 
> Yup, that's what I suspected.
> 
> > > If it's where I suspect it is, we are hitting a VFS inode that
> > > igrab() is failing on because I_FREEING is set and that is returning
> > > EAGAIN. Hence xfs_iget() sleeps for a short period and retries the
> > > lookup. If you've still got a system in this state, can you dump the
> > > xfs stats a few times about 5s apart i.e.
> > > 
> > > $ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done
> > > 
> > > Depending on what stat is changing (i'm looking for skip vs recycle
> > > in the inode cache stats), that will tell us why the lookup is
> > > failing...
> > 
> > $ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done
> > 
> > Mon Jul  1 09:29:57 CEST 2013
> > extent_alloc 1484333 2038118 1678 13182
> > abt 0 0 0 0
> > blk_map 21004635 3433178 1450438 1461372 1450017 25888309 0
> > bmbt 0 0 0 0
> > dir 1482235 1466711 7281 2529
> > trans 7676 6231535 1444850
> > ig 0 8534 299 1463749 0 1256778 262381
>             ^^^
> 
> That is the recycle stat, which indicates we've found an inode being
> reclaimed. When it's found an inode that have been evicted, but not
> yet reclaimed at the XFS level, that stat will increase. If the
> inode is still valid at the VFS level, and igrab() fails, then we'll
> get EAGAIN without that stat being increased. So, igrab() is
> failing, and that means I_FREEING|I_WILL_FREE are set.
> 
> So, it looks to be the same case as the ext4 hang, and it's likely
> that we have some dangling inode dispose list somewhere. So, here's
> the fun part. Use tracing to grab the inode number that is stuck
> (tracepoint xfs::xfs_iget_skip), 

$ cat /sys/kernel/debug/tracing/trace_pipe > demon.trace.log &
$ pid=$!
$ sleep 10s ; kill $pid
$ awk '{print $1, $9}' demon.trace.log | sort -u
cc1-7561 0xf78d4f
cc1-9100 0x80b2a35

> and then run crash on the live kernel on the process that is looping,
> and find the struct xfs_inode and print it.  Use the inode number from
> the trace point to check you've got the right inode.

crash> bt -f 7561
 #4 [ffff88003744db40] xfs_iget at ffffffffa029c03e [xfs]
    ffff88003744db48: 0000000000000000 0000000000000000 
    ffff88003744db58: 0000000000013b40 ffff88003744dc30 
    ffff88003744db68: 0000000000000000 0000000000000000 
    ffff88003744db78: 0000000000f78d4f ffffffffa02dafec 
    ffff88003744db88: ffff88000c09e1c0 0000000000000008 
    ffff88003744db98: 0000000000000000 ffff88000c0a0ac0 
    ffff88003744dba8: ffff88003744dc18 0000000000000000 
    ffff88003744dbb8: ffff88003744dc08 ffffffffa02a8e98
crash> dis xfs_iget
[...]
0xffffffffa029c045 <xfs_iget+197>:      callq  0xffffffff812ca190 <radix_tree_lookup>
0xffffffffa029c04a <xfs_iget+202>:      test   %rax,%rax
0xffffffffa029c04d <xfs_iget+205>:      mov    %rax,-0x30(%rbp)

So the inode should be at -0x30(%rbp) which is
crash> struct xfs_inode.i_ino ffff88000c09e1c0
  i_ino = 16223567
crash> p /x 16223567
$15 = 0xf78d4f

> Th struct inode of the VFS inode is embedded into the struct
> xfs_inode, 

crash> struct -o xfs_inode.i_vnode ffff88000c09e1c0
struct xfs_inode {
  [ffff88000c09e2f8] struct inode i_vnode;
}

> and the dispose list that it is on should be the on the
> inode->i_lru_list. 

crash> struct inode.i_lru ffff88000c09e2f8
  i_lru = {
    next = 0xffff88000c09e3e8, 
    prev = 0xffff88000c09e3e8
  }
crash> struct inode.i_flags ffff88000c09e2f8
  i_flags = 4096

The full xfs_inode dump is attached.

> What that, and see how many other inodes are on that list. Once we
> know if it's a single inode,

The list seems to be empty. And the same is the case for the other inode:
crash> bt -f 9100
 #4 [ffff88001c8c5b40] xfs_iget at ffffffffa029c03e [xfs]
    ffff88001c8c5b48: 0000000000000000 0000000000000000 
    ffff88001c8c5b58: 0000000000013b40 ffff88001c8c5c30 
    ffff88001c8c5b68: 0000000000000000 0000000000000000 
    ffff88001c8c5b78: 00000000000b2a35 ffffffffa02dafec 
    ffff88001c8c5b88: ffff88000c09ec40 0000000000000008 
    ffff88001c8c5b98: 0000000000000000 ffff8800359e9b00 
    ffff88001c8c5ba8: ffff88001c8c5c18 0000000000000000 
    ffff88001c8c5bb8: ffff88001c8c5c08 ffffffffa02a8e98
crash> p /x 0xffff88001c8c5bb8-0x30
$16 = 0xffff88001c8c5b88
sh> struct xfs_inode.i_ino ffff88000c09ec40
  i_ino = 134949429
crash> p /x 134949429
$17 = 0x80b2a35
crash> struct -o xfs_inode.i_vnode ffff88000c09ec40
struct xfs_inode {
  [ffff88000c09ed78] struct inode i_vnode;
}
crash> struct inode.i_lru ffff88000c09ed78
  i_lru = {
    next = 0xffff88000c09ee68, 
    prev = 0xffff88000c09ee68
  }
crash> struct inode.i_flags ffff88000c09ed78
  i_flags = 4096

> and whether the dispose list it is on is intact, empty or corrupt, we
> might have a better idea of how these inodes are getting lost....
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
Michal Hocko
SUSE Labs

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfs_inode

crash> struct xfs_inode ffff88000c09e1c0
struct xfs_inode {
  i_mount = 0xffff88001ca4d000, 
  i_udquot = 0x0, 
  i_gdquot = 0x0, 
  i_ino = 16223567, 
  i_imap = {
    im_blkno = 8111776, 
    im_len = 16, 
    im_boffset = 3840
  }, 
  i_afp = 0x0, 
  i_df = {
    if_bytes = 16, 
    if_real_bytes = 0, 
    if_broot = 0x0, 
    if_broot_bytes = 0, 
    if_flags = 2 '\002', 
    if_u1 = {
      if_extents = 0xffff88000c09e218, 
      if_ext_irec = 0xffff88000c09e218, 
      if_data = 0xffff88000c09e218 ""
    }, 
    if_u2 = {
      if_inline_ext = {{
          l0 = 0, 
          l1 = 2135699750913
        }, {
          l0 = 0, 
          l1 = 0
        }}, 
      if_inline_data = "\000\000\000\000\000\000\000\000\001\000\240A\361\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
      if_rdev = 0, 
      if_uuid = {
        __u_bits = "\000\000\000\000\000\000\000\000\001\000\240A\361\001\000"
      }
    }
  }, 
  i_itemp = 0x0, 
  i_lock = {
    mr_lock = {
      count = 0, 
      wait_lock = {
        raw_lock = {
          {
            head_tail = 0, 
            tickets = {
              head = 0, 
              tail = 0
            }
          }
        }
      }, 
      wait_list = {
        next = 0xffff88000c09e250, 
        prev = 0xffff88000c09e250
      }
    }
  }, 
  i_iolock = {
    mr_lock = {
      count = 0, 
      wait_lock = {
        raw_lock = {
          {
            head_tail = 0, 
            tickets = {
              head = 0, 
              tail = 0
            }
          }
        }
      }, 
      wait_list = {
        next = 0xffff88000c09e270, 
        prev = 0xffff88000c09e270
      }
    }
  }, 
  i_pincount = {
    counter = 0
  }, 
  i_flags_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 878654559, 
            tickets = {
              head = 13407, 
              tail = 13407
            }
          }
        }
      }
    }
  }, 
  i_flags = 0, 
  i_delayed_blks = 0, 
  i_d = {
    di_magic = 18766, 
    di_mode = 33204, 
    di_version = 2 '\002', 
    di_format = 2 '\002', 
    di_onlink = 0, 
    di_uid = 0, 
    di_gid = 0, 
    di_nlink = 1, 
    di_projid_lo = 0, 
    di_projid_hi = 0, 
    di_pad = "\000\000\000\000\000", 
    di_flushiter = 2, 
    di_atime = {
      t_sec = 1372433043, 
      t_nsec = 599568074
    }, 
    di_mtime = {
      t_sec = 1352637873, 
      t_nsec = 0
    }, 
    di_ctime = {
      t_sec = 1372432997, 
      t_nsec = 935341638
    }, 
    di_size = 3280, 
    di_nblocks = 1, 
    di_extsize = 0, 
    di_nextents = 1, 
    di_anextents = 0, 
    di_forkoff = 0 '\000', 
    di_aformat = 2 '\002', 
    di_dmevmask = 0, 
    di_dmstate = 0, 
    di_flags = 0, 
    di_gen = 15307555
  }, 
  i_vnode = {
    i_mode = 33204, 
    i_opflags = 5, 
    i_uid = 0, 
    i_gid = 0, 
    i_flags = 4096, 
    i_acl = 0x0, 
    i_default_acl = 0x0, 
    i_op = 0xffffffffa0301800, 
    i_sb = 0xffff88001e70c800, 
    i_mapping = 0xffff88000c09e440, 
    i_security = 0x0, 
    i_ino = 16223567, 
    {
      i_nlink = 1, 
      __i_nlink = 1
    }, 
    i_rdev = 0, 
    i_size = 3280, 
    i_atime = {
      tv_sec = 1372433043, 
      tv_nsec = 599568074
    }, 
    i_mtime = {
      tv_sec = 1352637873, 
      tv_nsec = 0
    }, 
    i_ctime = {
      tv_sec = 1372432997, 
      tv_nsec = 935341638
    }, 
    i_lock = {
      {
        rlock = {
          raw_lock = {
            {
              head_tail = 852898518, 
              tickets = {
                head = 13014, 
                tail = 13014
              }
            }
          }
        }
      }
    }, 
    i_bytes = 0, 
    i_blkbits = 12, 
    i_blocks = 0, 
    i_state = 32, 
    i_mutex = {
      count = {
        counter = 1
      }, 
      wait_lock = {
        {
          rlock = {
            raw_lock = {
              {
                head_tail = 0, 
                tickets = {
                  head = 0, 
                  tail = 0
                }
              }
            }
          }
        }
      }, 
      wait_list = {
        next = 0xffff88000c09e3a8, 
        prev = 0xffff88000c09e3a8
      }, 
      owner = 0x0
    }, 
    dirtied_when = 0, 
    i_hash = {
      next = 0x0, 
      pprev = 0xffff88000c09e3c8
    }, 
    i_wb_list = {
      next = 0xffff88000c09e3d8, 
      prev = 0xffff88000c09e3d8
    }, 
    i_lru = {
      next = 0xffff88000c09e3e8, 
      prev = 0xffff88000c09e3e8
    }, 
    i_sb_list = {
      next = 0xffff88000c0a0cf8, 
      prev = 0xffff880012423d38
    }, 
    {
      i_dentry = {
        first = 0x0
      }, 
      i_rcu = {
        next = 0x0, 
        func = 0xffffffffa029acb0 <xfs_inode_free_callback>
      }
    }, 
    i_version = 0, 
    i_count = {
      counter = 0
    }, 
    i_dio_count = {
      counter = 0
    }, 
    i_writecount = {
      counter = 0
    }, 
    i_fop = 0xffffffffa03015c0, 
    i_flock = 0x0, 
    i_data = {
      host = 0xffff88000c09e2f8, 
      page_tree = {
        height = 0, 
        gfp_mask = 32, 
        rnode = 0x0
      }, 
      tree_lock = {
        {
          rlock = {
            raw_lock = {
              {
                head_tail = 4849738, 
                tickets = {
                  head = 74, 
                  tail = 74
                }
              }
            }
          }
        }
      }, 
      i_mmap_writable = 0, 
      i_mmap = {
        rb_node = 0x0
      }, 
      i_mmap_nonlinear = {
        next = 0xffff88000c09e468, 
        prev = 0xffff88000c09e468
      }, 
      i_mmap_mutex = {
        count = {
          counter = 1
        }, 
        wait_lock = {
          {
            rlock = {
              raw_lock = {
                {
                  head_tail = 0, 
                  tickets = {
                    head = 0, 
                    tail = 0
                  }
                }
              }
            }
          }
        }, 
        wait_list = {
          next = 0xffff88000c09e480, 
          prev = 0xffff88000c09e480
        }, 
        owner = 0x0
      }, 
      nrpages = 0, 
      writeback_index = 0, 
      a_ops = 0xffffffffa0301460, 
      flags = 131290, 
      backing_dev_info = 0xffff88001c7b9950, 
      private_lock = {
        {
          rlock = {
            raw_lock = {
              {
                head_tail = 1835036, 
                tickets = {
                  head = 28, 
                  tail = 28
                }
              }
            }
          }
        }
      }, 
      private_list = {
        next = 0xffff88000c09e4c8, 
        prev = 0xffff88000c09e4c8
      }, 
      private_data = 0x0
    }, 
    i_dquot = {0x0, 0x0}, 
    i_devices = {
      next = 0xffff88000c09e4f0, 
      prev = 0xffff88000c09e4f0
    }, 
    {
      i_pipe = 0x0, 
      i_bdev = 0x0, 
      i_cdev = 0x0
    }, 
    i_generation = 15307555, 
    i_fsnotify_mask = 0, 
    i_fsnotify_marks = {
      first = 0x0
    }, 
    i_private = 0x0
  }
}

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
