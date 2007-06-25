Message-ID: <467F6882.9000800@vmware.com>
Date: Mon, 25 Jun 2007 00:02:26 -0700
From: Petr Vandrovec <petr@vmware.com>
MIME-Version: 1.0
Subject: 2.6.22-rc5-yesterdaygit with VM debug: BUG in mm/rmap.c:66: anon_vma_link
 ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
   to catch some memory corruption bug in our code I've modified malloc 
to do mmap + mprotect - which has unfortunate effect that it creates 
thousands and thousands of VMAs.  Everything works (though rather slowly 
on kernel with CONFIG_VM_DEBUG) until application does fork() - kernel 
crashes on fork() because copy_process()'s anon_vma_link complains that 
it could not find anon vma after walking through 100000 elements of anon 
list - which seems strange, as I did not touch system wide limit (which 
is 65536 vmas), and mprotect()s started failing after creating 65536 
vmas, as expected.

Full output of test program and full kernel dmesg are at 
http://buk.vc.cvut.cz/linux/rmap.
					Thanks,
						Petr Vandrovec


#include <sys/mman.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#define TRY_REGIONS 131072

int main(void) {
	unsigned char* ptr[TRY_REGIONS];
	int i;
	int fd;
	int badmprot = 0;
	char buf[16384];
	ssize_t l;

	printf("PID=%u\n", getpid());
	for (i = 0; i < TRY_REGIONS; i++) {
		ptr[i] = mmap(0, 8192, PROT_READ | PROT_WRITE, MAP_PRIVATE | 
MAP_ANONYMOUS, -1, 0);
		if (ptr[i] == MAP_FAILED) {
			break;
		}
		if (mprotect(ptr[i] + 4096, 4096, PROT_NONE)) {
			badmprot++;
		}
	}
	printf("Allocated %u regions, %u mprotects failed\n", i, badmprot);
	fflush(stdout);
	fd = open("/proc/self/maps", O_RDONLY);
	while ((l = read(fd, buf, sizeof buf)) > 0) {
		write(1, buf, l);
	}
	close(fd);
	fork();
	return 0;
}

PID=6101
Allocated 131072 regions, 98310 mprotects failed
08048000-08049000 r-xp 00000000 08:05 1163513 
  /root/test
08049000-0804a000 rw-p 00000000 08:05 1163513 
  /root/test
b7e37000-e7e44000 rw-p b7e37000 00:00 0
e7e44000-e7e45000 ---p e7e44000 00:00 0
e7e45000-e7e46000 rw-p e7e45000 00:00 0
[65525 lines removed]
f7f7b000-f7f7c000 ---p f7f7b000 00:00 0
f7f7c000-f7f7f000 rw-p f7f7c000 00:00 0
f7f7f000-f7f9a000 r-xp 00000000 08:05 15581230 
  /lib/ld-2.5.so
f7f9a000-f7f9c000 rw-p 0001b000 08:05 15581230 
  /lib/ld-2.5.so
ff869000-ff8ef000 rw-p ff869000 00:00 0 
  [stack]
ffffe000-fffff000 r-xp ffffe000 00:00 0 
  [vdso]

------------[ cut here ]------------
kernel BUG at /usr/src/linus/linux-2.6.22-rc5-7515/mm/rmap.c:66!
invalid opcode: 0000 [1] PREEMPT SMP
CPU 0
Modules linked in: binfmt_misc rfcomm l2cap nfs nfsd exportfs lockd 
nfs_acl sunrpc ipx p8022 psnap llc p8023 ppdev lp af_packet aoe deflate 
zlib_deflate zlib_inflate twofish twofish_common camellia serpent 
blowfish des cbc ecb blkcipher aes xcbc sha256 sha1 crypto_null hmac 
crypto_hash cryptomgr af_key nls_utf8 nls_iso8859_2 ntfs fuse sbp2 loop 
hci_usb raw1394 dv1394 bluetooth usb_storage usbhid libusual 
snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_timer firewire_ohci 
firewire_core sg snd crc_itu_t parport_pc parport sky2 k8temp 8250_pnp 
8250 serial_core sr_mod serio_raw hwmon sata_sil24 ohci1394 ieee1394 
ohci_hcd ehci_hcd cdrom snd_page_alloc usbcore i2c_nforce2
Pid: 6101, comm: test Not tainted 2.6.22-rc5-7515-64 #1
RIP: 0010:[<ffffffff802987bb>]  [<ffffffff802987bb>] anon_vma_link+0x8b/0xa0
RSP: 0018:ffff810111d4fd88  EFLAGS: 00010202
RAX: ffff8101109fb9e0 RBX: ffff8101109fb978 RCX: ffff8101109fb978
RDX: ffff810112fccf10 RSI: 00000000000186a1 RDI: 0000000000000000
RBP: ffff810111d4fd98 R08: ffff810112fccf10 R09: 0000000000000000
R10: ffffffff8029874b R11: 0000000000000000 R12: ffff810112fccee0
R13: 0000000001200011 R14: ffff810111590080 R15: ffff810111590080
FS:  0000000000000000(0000) GS:ffffffff80652000(0063) knlGS:00000000f7e196c0
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 00000000f7eaa7c0 CR3: 0000000111c17000 CR4: 00000000000006e0
Process test (pid: 6101, threadinfo ffff810111d4e000, task ffff810112fcf080)
Stack:  0000000000000001 ffff8101109fb978 ffff810111d4fe78 ffffffff8023817c
  ffffffff8061d688 ffff8101140e00e0 ffff8101115901b8 ffff81012560d148
  ffff8101115906a0 ffff810111ebd760 00000000f7e19708 0000000000000000
Call Trace:
  [<ffffffff8023817c>] copy_process+0xb9c/0x1760
  [<ffffffff8024dd72>] alloc_pid+0x212/0x320
  [<ffffffff80238ed3>] do_fork+0xa3/0x290
  [<ffffffff804c6880>] _spin_unlock+0x30/0x60
  [<ffffffff802aebb6>] __fput+0x176/0x1c0
  [<ffffffff80227ce7>] sys32_clone+0x27/0x30
  [<ffffffff802279d5>] ia32_ptregs_common+0x25/0x50


Code: 0f 0b eb fe 0f 0b eb fe 66 0f 1f 44 00 00 0f 1f 80 00 00 00
RIP  [<ffffffff802987bb>] anon_vma_link+0x8b/0xa0
  RSP <ffff810111d4fd88>
note: test[6101] exited with preempt_count 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
