Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABD916B0003
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 17:22:47 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id y90-v6so2505469ota.12
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 14:22:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k33-v6si1980455otb.172.2018.06.05.14.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 14:22:44 -0700 (PDT)
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
References: <bug-199931-27@https.bugzilla.kernel.org/>
 <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <34c7a73b-15d5-4d67-fa7c-0630b30a4c1c@i-love.sakura.ne.jp>
Date: Wed, 6 Jun 2018 06:22:25 +0900
MIME-Version: 1.0
In-Reply-To: <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Michal Hocko <mhocko@suse.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On 2018/06/06 5:03, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=199931
>>
>>             Bug ID: 199931
>>            Summary: systemd/rtorrent file data corruption when using echo
>>                     3 >/proc/sys/vm/drop_caches
> 
> A long tale of woe here.  Chris, do you think the pagecache corruption
> is a general thing, or is it possible that btrfs is contributing?

According to timestamp of my testcases, I was observing corrupted-bytes issue upon OOM-kill
(without using btrfs) as of 2017 Aug 11. Thus, I don't think that this is specific to btrfs.
But I can't find which patch fixed this issue.

----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <signal.h>

#define NUMTHREADS 512
#define STACKSIZE 8192

static int pipe_fd[2] = { EOF, EOF };
static int file_writer(void *i)
{
        char buffer[4096] = { };
        int fd;
        snprintf(buffer, sizeof(buffer), "/tmp/file.%lu", (unsigned long) i);
        fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
        memset(buffer, 0xFF, sizeof(buffer));
        read(pipe_fd[0], buffer, 1);
        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer));
        return 0;
}

int main(int argc, char *argv[])
{
        char *buf = NULL;
        unsigned long size;
        unsigned long i;
        char *stack;
        if (pipe(pipe_fd))
                return 1;
        stack = malloc(STACKSIZE * NUMTHREADS);
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        for (i = 0; i < NUMTHREADS; i++)
                if (clone(file_writer, stack + (i + 1) * STACKSIZE,
                          CLONE_THREAD | CLONE_SIGHAND | CLONE_VM | CLONE_FS |
                          CLONE_FILES, (void *) i) == -1)
                        break;
        close(pipe_fd[1]);
        /* Will cause OOM due to overcommit; if not use SysRq-f */
        for (i = 0; i < size; i += 4096)
                buf[i] = 0;
        kill(-1, SIGKILL);
        return 0;
}
----------------------------------------

----------------------------------------
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
        char buffer2[64] = { };
        int ret = 0;
        int i;
        for (i = 0; i < 1024; i++) {
                 int flag = 0;
                 int fd;
                 unsigned int byte[256];
                 int j;
                 snprintf(buffer2, sizeof(buffer2), "/tmp/file.%u", i);
                 fd = open(buffer2, O_RDONLY);
                 if (fd == EOF)
                         continue;
                 lseek(fd, -4096, SEEK_END);
                 memset(byte, 0, sizeof(byte));
                 while (1) {
                         static unsigned char buffer[1048576];
                         int len = read(fd, (char *) buffer, sizeof(buffer));
                         if (len <= 0)
                                 break;
                         for (j = 0; j < len; j++)
                                 if (buffer[j] != 0xFF)
                                         byte[buffer[j]]++;
                 }
                 close(fd);
                 for (j = 0; j < 255; j++)
                         if (byte[j]) {
                                 printf("ERROR: %u %u in %s\n", byte[j], j, buffer2);
                                 flag = 1;
                         }
                 if (flag == 0)
                         unlink(buffer2);
                 else
                         ret = 1;
        }
        return ret;
}
----------------------------------------
