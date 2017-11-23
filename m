Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 417766B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:38:25 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id i17so10130924otb.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:38:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 89si8132484ott.254.2017.11.23.04.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 04:38:24 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
 <f42fe774-bdcc-a509-bb7f-fe709fd28fcb@linux.intel.com>
 <9ec19ff3-86f6-7cfe-1a07-1ab1c5d9882c@redhat.com>
 <d98eb4b8-6e59-513d-fdf8-3395485cb851@linux.intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <28f6e430-293d-4b30-dce6-018a2b3c03e8@redhat.com>
Date: Thu, 23 Nov 2017 13:38:21 +0100
MIME-Version: 1.0
In-Reply-To: <d98eb4b8-6e59-513d-fdf8-3395485cb851@linux.intel.com>
Content-Type: multipart/mixed;
 boundary="------------FF525EDD2571B48E744E8AB5"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

This is a multi-part message in MIME format.
--------------FF525EDD2571B48E744E8AB5
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

On 11/22/2017 05:32 PM, Dave Hansen wrote:
> On 11/22/2017 08:21 AM, Florian Weimer wrote:
>> On 11/22/2017 05:10 PM, Dave Hansen wrote:
>>> On 11/22/2017 04:15 AM, Florian Weimer wrote:
>>>> On 11/22/2017 09:18 AM, Vlastimil Babka wrote:
>>>>> And, was the pkey == -1 internal wiring supposed to be exposed to the
>>>>> pkey_mprotect() signal, or should there have been a pre-check returning
>>>>> EINVAL in SYSCALL_DEFINE4(pkey_mprotect), before calling
>>>>> do_mprotect_pkey())? I assume it's too late to change it now anyway (or
>>>>> not?), so should we also document it?
>>>>
>>>> I think the -1 case to the set the default key is useful because it
>>>> allows you to use a key value of -1 to mean a??MPK is not supporteda??, and
>>>> still call pkey_mprotect.
>>>
>>> The behavior to not allow 0 to be set was unintentional and is a bug.
>>> We should fix that.
>>
>> On the other hand, x86-64 has no single default protection key due to
>> the PROT_EXEC emulation.
> 
> No, the default is clearly 0 and documented to be so.  The PROT_EXEC
> emulation one should be inaccessible in all the APIs so does not even
> show up as *being* a key in the API.

I see key 1 in /proc for a PROT_EXEC mapping.  If I supply an explicit 
protection key, that key is used, and the page ends up having read 
access enabled.

The key is also visible in the siginfo_t argument on read access to a 
PROT_EXEC mapping with the default key, so it's not just /proc:

page 1 (0x7f008242d000): read access denied
   SIGSEGV address: 0x7f008242d000
   SIGSEGV code: 4
   SIGSEGV key: 1

I'm attaching my test.

 > The fact that it's implemented
 > with pkeys should be pretty immaterial other than the fact that you
 > can't touch the high bits in PKRU.

I don't see a restriction for PKRU updates.  If I write zero to the PKRU 
register, PROT_EXEC implies PROT_READ, as I would expect.

This is with kernel 4.14.

Florian

--------------FF525EDD2571B48E744E8AB5
Content-Type: text/x-csrc;
 name="mpk-default.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mpk-default.c"

#include <err.h>
#include <setjmp.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <unistd.h>

#define PKEY_DISABLE_ACCESS 1
#define PKEY_DISABLE_WRITE 2

__attribute__ ((weak, noinline, noclone)) /* Compiler barrier.  */
void
touch (void *buffer)
{
}

__attribute__ ((weak, noinline, noclone)) /* Compiler barrier.  */
void
read_page (void *page)
{
  char buf[16];
  memcpy (buf, page, sizeof (buf));
  touch (buf);
}

__attribute__ ((weak, noinline, noclone)) /* Compiler barrier.  */
void
write_page (void *page)
{
  memset (page, 0, 16);
  touch (page);
}

static volatile void *sigsegv_addr;
static volatile int sigsegv_code;
static volatile int sigsegv_pkey;
static sigjmp_buf sigsegv_jmp;

static void
sigsegv_handler (int signo, siginfo_t *info, void *arg)
{
  sigsegv_addr = info->si_addr;
  sigsegv_code = info->si_code;
  if (info->si_code == 4)
    {
      /* Guess the address of the protection key field.  */
      int *ppkey = 2 + ((int *)((&info->si_addr) + 1));
      sigsegv_pkey = *ppkey;
    }
  else
    sigsegv_pkey = -1;
  siglongjmp (sigsegv_jmp, 2);
}

static const struct sigaction sigsegv_sigaction =
  {
    .sa_flags = SA_RESETHAND | SA_SIGINFO,
    .sa_sigaction = &sigsegv_handler,
  };

/* Return the value of the PKRU register.  */
static inline unsigned int
pkey_read (void)
{
  unsigned int result;
  __asm__ volatile (".byte 0x0f, 0x01, 0xee"
                    : "=a" (result) : "c" (0) : "rdx");
  return result;
}

/* Overwrite the PKRU register with VALUE.  */
static inline void
pkey_write (unsigned int value)
{
  __asm__ volatile (".byte 0x0f, 0x01, 0xef"
                    : : "a" (value), "c" (0), "d" (0));
}

enum { page_count = 7 };
static void *pages[page_count];

static void
check_fault_1 (int page, const char *what, void (*op) (void *))
{
  unsigned pkru = pkey_read ();

  int result = sigsetjmp (sigsegv_jmp, 1);
  if (result == 0)
    {
      if (sigaction (SIGSEGV, &sigsegv_sigaction, NULL) != 0)
	err (1, "sigaction");
      op (pages[page]);
      printf ("page %d (%p): %s access allowed\n", page, pages[page], what);
      return;
    }
  else
    {
      if (signal (SIGSEGV, SIG_DFL) == SIG_ERR)
	err (1, "signal");
      printf ("page %d (%p): %s access denied\n", page, pages[page], what);
      printf ("  SIGSEGV address: %p\n", sigsegv_addr);
      printf ("  SIGSEGV code: %d\n", sigsegv_code);
      printf ("  SIGSEGV key: %d\n", sigsegv_pkey);
    }

  /* Preserve PKRU register value (clobbered by signal handler).  */
  pkey_write (pkru);
}

static void
check_fault (int page)
{
  check_fault_1 (page, "read", read_page);
  check_fault_1 (page, "write", write_page);
}

static void
dump_smaps (const char *what)
{
  printf ("info: *** BEGIN %s ***\n", what);
  FILE *fp = fopen ("/proc/self/smaps", "r");
  if (fp == NULL)
    err (1, "fopen");
  while (true)
    {
      int ch = fgetc (fp);
      if (ch == EOF)
	break;
      fputc (ch, stdout);
    }
  if (ferror (fp))
    err (1, "fgetc");
  if (fclose (fp) != 0)
    err (1, "fclose");
  printf ("info: *** END %s ***\n", what);
  fflush (stdout);
}

int
main (void)
{
  int protections[page_count] = 
    { PROT_READ | PROT_WRITE, PROT_EXEC, PROT_READ, PROT_READ,
      PROT_EXEC | PROT_WRITE, PROT_EXEC | PROT_WRITE, PROT_EXEC };
  for (int i = 0; i < page_count; ++i)
    {
      pages[i] = mmap (NULL, 1, protections[i],
		       MAP_ANON | MAP_PRIVATE, -1, 0);
      if (pages[i] == MAP_FAILED)
	err (1, "mmap");
      printf ("page %d: %p\n", i, pages[i]);
    }
      
  int key = syscall (SYS_pkey_alloc, 0, 0);
  if (key < 0)
    err (1, "pkey_alloc");
  printf ("key: %d\n", key);

  if (syscall (SYS_pkey_mprotect, pages[2], 1, PROT_READ, key) != 0)
    err (1, "pkey_mprotected (pages[2])");
  if (syscall (SYS_pkey_mprotect, pages[3], 1, PROT_EXEC, key) != 0)
    err (1, "pkey_mprotected (pages[3])");
  if (syscall (SYS_pkey_mprotect, pages[5], 1, PROT_EXEC | PROT_WRITE, key)
      != 0)
    err (1, "pkey_mprotected (pages[5])");
  if (syscall (SYS_pkey_mprotect, pages[6], 1, PROT_EXEC, key) != 0)
    err (1, "pkey_mprotected (pages[6])");
  if (syscall (SYS_pkey_mprotect, pages[6], 1, PROT_EXEC, -1) != 0)
    err (1, "pkey_mprotected (pages[6])");

  dump_smaps ("dump before faults");

  /* This succeeds because the page is mapped readable.  */
  puts ("info: performing accesses");
  fflush (stdout);
  for (int i = 0; i < page_count; ++i)
    check_fault (i);

  /* See what happens if we grant all access rights.  */
  puts ("info: setting PKRU to zero");
  fflush (stdout);
  pkey_write (0);

  for (int i = 0; i < page_count; ++i)
    check_fault (i);

  return 0;
}

--------------FF525EDD2571B48E744E8AB5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
